`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 07:32:42 PM
// Design Name: 
// Module Name: Demo_RGB_TO_GRAYSCALE_Design_Source
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

module Demo_RGB_TO_GRAYSCALE_Design_Source(
    input            StreamClk,        
    input            sStreamReset_n,    

    input            s_axis_video_tvalid, 
    input  [23:0]    s_axis_video_tdata,  
    input            s_axis_video_tlast,  
    input            s_axis_video_tuser,  
    output           s_axis_video_tready, 

    output reg       m_axis_video_tvalid, 
    output reg [23:0] m_axis_video_tdata,  
    output reg       m_axis_video_tlast,  
    output reg       m_axis_video_tuser,  
    input            m_axis_video_tready  
    );
    
wire [7:0] w_red;
wire [7:0] w_green;
wire [7:0] w_blue;
wire [7:0] w_grey_calculated;

reg [23:0] m_axis_video_tdata_reg;
reg        m_axis_video_tlast_reg;
reg        m_axis_video_tuser_reg;
reg        m_axis_video_tvalid_reg = 1'b0; 

assign w_red   = s_axis_video_tdata[7:0];
assign w_green = s_axis_video_tdata[15:8];
assign w_blue  = s_axis_video_tdata[23:16];


assign w_grey_calculated = (w_red >> 2) + (w_red >> 5) + (w_green >> 1) + (w_green >> 4) + (w_blue >> 4) + (w_blue >> 5);

assign s_axis_video_tready = m_axis_video_tready || !m_axis_video_tvalid_reg;

always @(posedge StreamClk or negedge sStreamReset_n) begin
    if (!sStreamReset_n) begin
        
        m_axis_video_tdata_reg <= 24'b0;
        m_axis_video_tlast_reg <= 1'b0;
        m_axis_video_tuser_reg <= 1'b0;
        m_axis_video_tvalid_reg <= 1'b0;
    end else begin
       
        if (s_axis_video_tvalid && s_axis_video_tready) begin
           
            m_axis_video_tdata_reg <= {w_grey_calculated, w_grey_calculated, w_grey_calculated};
            m_axis_video_tlast_reg <= s_axis_video_tlast;
            m_axis_video_tuser_reg <= s_axis_video_tuser;
            m_axis_video_tvalid_reg <= 1'b1;
        end
       
        else if (m_axis_video_tvalid_reg && m_axis_video_tready) begin
           
            m_axis_video_tvalid_reg <= 1'b0;
        end
    end
end

always @(*) begin
   m_axis_video_tvalid = m_axis_video_tvalid_reg;
   m_axis_video_tdata  = m_axis_video_tdata_reg;
   m_axis_video_tlast  = m_axis_video_tlast_reg;
   m_axis_video_tuser  = m_axis_video_tuser_reg;
end

endmodule
