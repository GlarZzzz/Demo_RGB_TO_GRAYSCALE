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
    input            aclk,        
    input            aresetn,    

    input            s_axis_tvalid, 
    input  [23:0]    s_axis_tdata,  
    input            s_axis_tlast,  
    input            s_axis_tuser,  
    output           s_axis_tready, 

    output reg       m_axis_tvalid, 
    output reg [23:0] m_axis_tdata,  
    output reg       m_axis_tlast,  
    output reg       m_axis_tuser,  
    input            m_axis_tready  
    );
    
wire [7:0] w_red;
wire [7:0] w_green;
wire [7:0] w_blue;
wire [7:0] w_grey_calculated;

reg [23:0] m_axis_tdata_reg;
reg        m_axis_tlast_reg;
reg        m_axis_tuser_reg;
reg        m_axis_tvalid_reg = 1'b0; 

assign w_red   = s_axis_tdata[7:0];
assign w_green = s_axis_tdata[15:8];
assign w_blue  = s_axis_tdata[23:16];


assign w_grey_calculated = (w_red >> 2) + (w_red >> 5) + (w_green >> 1) + (w_green >> 4) + (w_blue >> 4) + (w_blue >> 5);

assign s_axis_tready = m_axis_tready || !m_axis_tvalid_reg;

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        
        m_axis_tdata_reg <= 24'b0;
        m_axis_tlast_reg <= 1'b0;
        m_axis_tuser_reg <= 1'b0;
        m_axis_tvalid_reg <= 1'b0;
    end else begin
       
        if (s_axis_tvalid && s_axis_tready) begin
           
            m_axis_tdata_reg <= {w_grey_calculated, w_grey_calculated, w_grey_calculated};
            m_axis_tlast_reg <= s_axis_tlast;
            m_axis_tuser_reg <= s_axis_tuser;
            m_axis_tvalid_reg <= 1'b1;
        end
       
        else if (m_axis_tvalid_reg && m_axis_tready) begin
           
            m_axis_tvalid_reg <= 1'b0;
        end
    end
end

always @(*) begin
   m_axis_tvalid = m_axis_tvalid_reg;
   m_axis_tdata  = m_axis_tdata_reg;
   m_axis_tlast  = m_axis_tlast_reg;
   m_axis_tuser  = m_axis_tuser_reg;
end

endmodule
