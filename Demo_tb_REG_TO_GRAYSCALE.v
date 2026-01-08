`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 07:35:25 PM
// Design Name: 
// Module Name: Demo_tb_REG_TO_GRAYSCALE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_Demo_RGB_TO_GRAYSCALE
// Description: Testbench for RGB to Grayscale module using HEX file I/O
//////////////////////////////////////////////////////////////////////////////////

module tb_Demo_RGB_TO_GRAYSCALE;

    // Parameters for Image Size (Must match your input hex file size)
    parameter IMAGE_WIDTH  = 640;  
    parameter IMAGE_HEIGHT = 480;   
    parameter TOTAL_PIXELS = IMAGE_WIDTH * IMAGE_HEIGHT;
    
    // File Paths
    parameter INPUT_FILENAME  = "input_pixels_rgb.hex";  
    parameter OUTPUT_FILENAME = "image_gray_out.hex"; 
    // Inputs to DUT
    reg aclk;
    reg aresetn;
    reg s_axis_tvalid;
    reg [23:0] s_axis_tdata;
    reg s_axis_tlast;
    reg s_axis_tuser;
    reg m_axis_tready;

    // Outputs from DUT
    wire s_axis_tready;
    wire m_axis_tvalid;
    wire [23:0] m_axis_tdata;
    wire m_axis_tlast;
    wire m_axis_tuser;

    // Clock Period (Example 100MHz)
    localparam CLK_PERIOD = 10;

    // Memory to store input image
    reg [23:0] img_data [0:TOTAL_PIXELS-1];
    
    // File handle for output
    integer file_out;
    integer i;
    integer x_cnt, y_cnt;

    // -------------------------------------------------------------------------
    // Instantiate the Device Under Test (DUT)
    // -------------------------------------------------------------------------
    Demo_RGB_TO_GRAYSCALE_Design_Source dut_instant (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tuser(s_axis_tuser),
        .s_axis_tready(s_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser),
        .m_axis_tready(m_axis_tready)
    );

    // -------------------------------------------------------------------------
    // Clock Generation
    // -------------------------------------------------------------------------
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD/2) aclk = ~aclk;
    end

    // -------------------------------------------------------------------------
    // Main Stimulus Process (Input Driver)
    // -------------------------------------------------------------------------
    initial begin
        // 1. Initialize Inputs
        aresetn = 0;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        s_axis_tlast = 0;
        s_axis_tuser = 0;
        m_axis_tready = 0; // Initially not ready to receive

        // 2. Load Image Data from HEX file
        // Format of hex file should be one pixel per line (e.g., FFFFFF for white)
        $readmemh(INPUT_FILENAME, img_data);
        $display("Loaded input image data from %s", INPUT_FILENAME);

        // 3. Open Output File
        file_out = $fopen(OUTPUT_FILENAME, "w");
        if (file_out == 0) begin
            $display("Error: Could not open output file!");
            $finish;
        end

        // 4. Apply Reset
        #(CLK_PERIOD*10);
        aresetn = 1;
        #(CLK_PERIOD*5);


        $display("Starting image processing simulation...");
        

        m_axis_tready = 1; 

        x_cnt = 0;
        y_cnt = 0;

        for (i = 0; i < TOTAL_PIXELS; i = i + 1) begin

            wait(s_axis_tready);
            
            @(posedge aclk);
            s_axis_tvalid = 1;
            s_axis_tdata  = img_data[i];
            
            // Handle TUSER (Start of Frame - First pixel only)
            if (i == 0)
                s_axis_tuser = 1;
            else
                s_axis_tuser = 0;

            // Handle TLAST (End of Line)
            if (x_cnt == IMAGE_WIDTH - 1) begin
                s_axis_tlast = 1;
                x_cnt = 0;
                y_cnt = y_cnt + 1;
            end else begin
                s_axis_tlast = 0;
                x_cnt = x_cnt + 1;
            end
        end

        // End of transmission
        @(posedge aclk);
        s_axis_tvalid = 0;
        s_axis_tlast  = 0;
        s_axis_tuser  = 0;
        
        // Wait for all data to flush out
        #(CLK_PERIOD * 100);
        
        $display("Simulation Finished. Output written to %s", OUTPUT_FILENAME);
        $fclose(file_out);
        $finish;
    end

    // -------------------------------------------------------------------------
    // Output Monitor Process (Data Capture)
    // -------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (aresetn && m_axis_tvalid && m_axis_tready) begin
            // Write the processed pixel to the output hex file
            // The output format will be XX XX XX (Grey Grey Grey)
            $fwrite(file_out, "%h\n", m_axis_tdata);
        end
    end

endmodule
