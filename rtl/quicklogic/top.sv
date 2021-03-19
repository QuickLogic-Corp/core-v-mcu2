`timescale 1ns / 1ns
//
// `include "pulp_soc_defines.sv"
module top1 
  (
   input [5:0]         CLK,
   input [3:0]         RESET,
   input               lint_REQ, lint_WEN,
   
   input [19:0]        lint_ADDR, //PADDR,
   input [31:0]        lint_WDATA, //PWDATA,
   input [3:0]         lint_BE,
   output logic        lint_VALID, lint_GNT, //PREADY, PSLVERR,
   output logic [31:0] lint_RDATA, //PRDATA,
   
   output              APB_CLK,
   
   output [79:0]       fpgaio_out, fpgaio_oe,
   input [79:0]        fpgaio_in,
   output [15:0]       events_o,
   
   input [31:0]        m0_oper0_rdata, m0_oper1_rdata, m0_coef_rdata, 
   output [1:0]        m0_oper0_rmode, m0_oper0_wmode, m0_oper1_rmode, m0_oper1_wmode,
   output logic        m0_oper0_wdsel, m0_oper0_we, m0_oper0_rclk, m0_oper0_wclk,
   output logic        m0_oper1_wdsel, m0_oper1_we, m0_oper1_rclk, m0_oper1_wclk,
   output logic [11:0] m0_oper0_waddr, m0_oper0_raddr, m0_oper1_waddr, m0_oper1_raddr,
   output logic [11:0] m0_coef_raddr, m0_coef_waddr,
   output logic [31:0] m0_oper0_wdata, m0_oper1_wdata, m0_coef_wdata,
   output [1:0]        m0_coef_rmode, m0_coef_wmode,
   output logic        m0_coef_wdsel, m0_coef_we, m0_coef_rclk, m0_coef_wclk,
   output              m0_oper0_powerdn,m0_oper1_powerdn,m0_coef_powerdn,
	     
   output [31:0]       m0_m0_oper_in, m0_m0_coef_in, m0_m1_oper_in, m0_m1_coef_in,
   input [31:0]        m0_m0_dataout, m0_m1_dataout,
   output [5:0]        m0_m0_outsel, m0_m1_outsel,
   output              m0_m0_tc, m0_m1_tc,
   output logic        m0_m0_clk, m0_m1_clk, m0_m0_clken, m0_m1_clken,
   output              m0_m0_osel, m0_m0_csel, m0_m1_osel, m0_m1_csel,
   output [1:0]        m0_m0_mode, m0_m1_mode,
   output              m0_m0_sat, m0_m0_clr, m0_m0_rnd, m0_m1_sat, m0_m1_clr, m0_m1_rnd,
   output              m0_m0_reset, m0_m1_reset,

   input [31:0]        m1_oper0_rdata, m1_oper1_rdata, m1_coef_rdata, 
   output [1:0]        m1_oper0_rmode, m1_oper0_wmode, m1_oper1_rmode, m1_oper1_wmode,
   output logic        m1_oper0_wdsel, m1_oper0_we, m1_oper0_rclk, m1_oper0_wclk,
   output logic        m1_oper1_wdsel, m1_oper1_we, m1_oper1_rclk, m1_oper1_wclk,
   output logic [11:0] m1_oper0_waddr, m1_oper0_raddr, m1_oper1_waddr, m1_oper1_raddr,
   output logic [11:0] m1_coef_raddr, m1_coef_waddr,
   output logic [31:0] m1_oper0_wdata, m1_oper1_wdata, m1_coef_wdata,
   output [1:0]        m1_coef_rmode, m1_coef_wmode,
   output logic        m1_coef_wdsel, m1_coef_we, m1_coef_rclk, m1_coef_wclk,
   output              m1_oper0_powerdn, m1_oper1_powerdn, m1_coef_powerdn,
	     
   output [31:0]       m1_m0_oper_in, m1_m0_coef_in, m1_m1_oper_in, m1_m1_coef_in,
   input [31:0]        m1_m0_dataout, m1_m1_dataout,
   output [5:0]        m1_m0_outsel, m1_m1_outsel,
   output              m1_m0_tc, m1_m1_tc,
   output logic        m1_m0_clk, m1_m1_clk, m1_m0_clken, m1_m1_clken,
   output              m1_m0_osel, m1_m0_csel, m1_m1_osel, m1_m1_csel,
   output [1:0]        m1_m0_mode, m1_m1_mode,
   output              m1_m0_sat, m1_m0_clr, m1_m0_rnd, m1_m1_sat, m1_m1_clr, m1_m1_rnd,
   output              m1_m0_reset, m1_m1_reset,

   output logic [19:0] tcdm_addr_p0,tcdm_addr_p1,tcdm_addr_p2,tcdm_addr_p3,
   input [31:0]        tcdm_rdata_p0, tcdm_rdata_p1, tcdm_rdata_p2, tcdm_rdata_p3,
   input               tcdm_valid_p0, tcdm_valid_p1, tcdm_valid_p2, tcdm_valid_p3,
   input               tcdm_gnt_p0, tcdm_gnt_p1, tcdm_gnt_p2, tcdm_gnt_p3, 
   output logic [31:0] tcdm_wdata_p0, tcdm_wdata_p1, tcdm_wdata_p2, tcdm_wdata_p3,
   output logic [3:0]  tcdm_be_p0, tcdm_be_p1, tcdm_be_p2, tcdm_be_p3,
   output logic        tcdm_we_p0, tcdm_we_p1, tcdm_we_p2, tcdm_we_p3,
   output logic        tcdm_req_p0, tcdm_req_p1, tcdm_req_p2, tcdm_req_p3,
   output              tcdm_clk_p0, tcdm_clk_p1, tcdm_clk_p2, tcdm_clk_p3
	     );

   logic [3:0]			apb_fsm;
   logic [31:0] 		m0_m0_control, m0_m1_control, m1_m0_control, m1_m1_control;
   logic [31:0] 		m0_ram_control, m1_ram_control;
   logic [15:0] 		i_events ;
   logic [79:0] 		ifpga_out, ifpga_oe;
   logic [31:0] 		tcdm_result_p0,tcdm_result_p1,tcdm_result_p2,tcdm_result_p3;
   logic [2:0] 			cnt5,cnt4,cnt3,cnt2,cnt1;
   
   logic                        saved_REQ;
   
   
   parameter IDLE = 0, ENABLE = 1, READ = 2, WRITE = 3;
   parameter READ_WAIT = 4, READ_DONE = 5;


   assign m0_oper0_powerdn = 0;
   assign m0_oper1_powerdn = 0;
   assign m0_coef_powerdn = 0;
   assign m1_oper0_powerdn = 0;
   assign m1_oper1_powerdn = 0;
   assign m1_coef_powerdn = 0;


   assign APB_CLK = CLK[0];

   assign m0_oper0_rclk = CLK[0];
   assign m0_oper1_rclk = CLK[0];
   assign m0_coef_rclk = CLK[0];
   assign m0_oper0_wclk = CLK[0];
   assign m0_oper1_wclk = CLK[0];
   assign m0_coef_wclk = CLK[0];
   assign m0_m0_clk = CLK[0];
   assign m0_m1_clk = CLK[0];
   
   assign m1_oper0_rclk = CLK[0];
   assign m1_oper1_rclk = CLK[0];
   assign m1_coef_rclk = CLK[0];
   assign m1_oper0_wclk = CLK[0];
   assign m1_oper1_wclk = CLK[0];
   assign m1_coef_wclk = CLK[0];
   assign m1_m0_clk = CLK[0];
   assign m1_m1_clk = CLK[0];
   
   assign tcdm_clk_p0 = CLK[0];
   assign tcdm_clk_p1 = CLK[0];
   assign tcdm_clk_p2 = CLK[0];
   assign tcdm_clk_p3 = CLK[0];
   
   
   
   assign m0_m0_outsel = m0_m0_control[5:0];
   assign m0_m0_tc = m0_m0_control[6];
   assign m0_m0_mode = m0_m0_control[13:12];
   assign m0_m0_osel = m0_m0_control[14];
   assign m0_m0_csel = m0_m0_control[15];
   assign m0_m0_rnd = m0_m0_control[16];
   assign m0_m0_clr = m0_m0_control[17];
   assign m0_m0_sat = m0_m0_control[18];
   assign m0_m0_reset = m0_m0_control[31];

   assign m0_m1_outsel = m0_m1_control[5:0];
   assign m0_m1_tc = m0_m1_control[6];
   assign m0_m1_mode = m0_m1_control[13:12];
   assign m0_m1_osel = m0_m1_control[14];
   assign m0_m1_csel = m0_m1_control[15];
   assign m0_m1_rnd = m0_m1_control[16];
   assign m0_m1_clr = m0_m1_control[17];
   assign m0_m1_sat = m0_m1_control[18];
   assign m0_m1_reset = m0_m1_control[31];

   assign m0_oper0_rmode = m0_ram_control[1:0];
   assign m0_oper0_wmode = m0_ram_control[3:2];
   assign m0_oper1_rmode = m0_ram_control[5:4];
   assign m0_oper1_wmode = m0_ram_control[7:6];
   assign m0_coef_rmode = m0_ram_control[9:8];
   assign m0_coef_wmode = m0_ram_control[11:10];
   assign m0_oper0_wdsel = m0_ram_control[12];
   assign m0_oper1_wdsel = m0_ram_control[13];
   assign m0_coef_wdsel = m0_ram_control[14];

   assign m1_m0_outsel = m1_m0_control[5:0];
   assign m1_m0_tc = m1_m0_control[6];
   assign m1_m0_mode = m1_m0_control[13:12];
   assign m1_m0_osel = m1_m0_control[14];
   assign m1_m0_csel = m1_m0_control[15];
   assign m1_m0_rnd = m1_m0_control[16];
   assign m1_m0_clr = m1_m0_control[17];
   assign m1_m0_sat = m1_m0_control[18];
   assign m1_m0_reset = m1_m0_control[31];

   assign m1_m1_outsel = m0_m0_control[5:0];
   assign m1_m1_tc = m1_m1_control[6];
   assign m1_m1_mode = m1_m1_control[13:12];
   assign m1_m1_osel = m1_m1_control[14];
   assign m1_m1_csel = m1_m1_control[15];
   assign m1_m1_rnd = m1_m1_control[16];
   assign m1_m1_clr = m1_m1_control[17];
   assign m1_m1_sat = m1_m1_control[18];
   assign m1_m1_reset = m1_m1_control[31];
   
   assign m1_oper0_rmode = m0_ram_control[1:0];
   assign m1_oper0_wmode = m0_ram_control[3:2];
   assign m1_oper1_rmode = m0_ram_control[5:4];
   assign m1_oper1_wmode = m0_ram_control[7:6];
   assign m1_coef_rmode = m0_ram_control[9:8];
   assign m1_coef_wmode = m0_ram_control[11:10];
   assign m1_oper0_wdsel = m0_ram_control[12];
   assign m1_oper1_wdsel = m0_ram_control[13];
   assign m1_coef_wdsel = m0_ram_control[14];



   assign fpgaio_out = ifpga_out;
   assign fpgaio_oe = ifpga_oe;
   assign events_o = fpgaio_in[15:0]; //i_events;


   assign m0_m0_oper_in = m0_oper0_rdata;
   assign m0_m1_oper_in = m0_oper1_rdata;
   assign m0_m0_coef_in = m0_coef_rdata;
   assign m0_m1_coef_in = m0_coef_rdata;
   assign m1_m0_oper_in = m1_oper0_rdata;
   assign m1_m1_oper_in = m1_oper1_rdata;
   assign m1_m0_coef_in = m1_coef_rdata;
   assign m1_m1_coef_in = m1_coef_rdata;
   
   always @ (posedge CLK[1] or negedge RESET[1]) begin
      if (RESET[1] == 0)
	cnt1 <= '0;
      else
	cnt1 <= cnt1 + 1;
   end
   always @ (posedge CLK[2] or negedge RESET[2]) begin
      if (RESET[2] == 0)
	cnt2 <= '0;
      else
	cnt2 <= cnt2 + 1;
   end
   always @ (posedge CLK[3] or negedge RESET[3]) begin
      if (RESET[3] == 0)
	cnt3 <= '0;
      else
	cnt3 <= cnt3 + 1;
   end
   always @ (posedge CLK[4] or negedge RESET[1]) begin
      if (RESET[1] == 0)
	cnt4 <= '0;
      else
	cnt4 <= cnt4 + 1;
   end
   always @ (posedge CLK[5] or negedge RESET[2]) begin
      if (RESET[2] == 0)
	cnt5 <= '0;
      else
	cnt5 <= cnt5 + 1;
   end
      
   always @ (posedge CLK[0] or negedge RESET[0]) begin
      if (RESET[0] == 0 ) begin
         lint_GNT <= 0;
         lint_VALID <= 0;
         lint_RDATA <= '0;
	 ifpga_out <= '0;
	 ifpga_oe <= '0;
	 i_events <= '0;
	 
	 tcdm_result_p0 <= '0;
	 tcdm_result_p1 <= '0;
	 tcdm_result_p2 <= '0;
	 tcdm_result_p3 <= '0;
	 
	 m0_m0_control <= 0;
	 m0_m1_control <= 0;
	 m0_ram_control <= 0;
	 m1_m0_control <= 0;
	 m1_m1_control <= 0;
	 m1_ram_control <= 0;
	 
	 tcdm_addr_p0 <= 0;
         tcdm_addr_p1 <= 0;
         tcdm_addr_p2 <= 0;
         tcdm_addr_p3 <= 0;
	 tcdm_wdata_p0 <= 0;
         tcdm_wdata_p1 <= 0;
         tcdm_wdata_p2 <= 0;
         tcdm_wdata_p3 <= 0;
	 tcdm_req_p0 <= 0;
	 tcdm_req_p1 <= 0;
	 tcdm_req_p2 <= 0;
	 tcdm_req_p3 <= 0;
	 apb_fsm <= IDLE;
	 m0_oper0_waddr <= 0;
	 m0_oper0_raddr <= 0;
	 m0_oper0_wdata <= 0;
	 m0_oper0_we <= 0;
	 m0_oper1_waddr <= 0;
	 m0_oper1_raddr <= 0;
	 m0_oper1_wdata <= 0;
	 m0_oper1_we <= 0;
	 m0_coef_waddr <= 0;
	 m0_coef_raddr <= 0;
	 m0_coef_wdata <= 0;
	 m0_coef_we <= 0;
	 
	 m1_oper0_waddr <= 0;
	 m1_oper0_raddr <= 0;
	 m1_oper0_wdata <= 0;
	 m1_oper0_we <= 0;
	 m1_oper1_waddr <= 0;
	 m1_oper1_raddr <= 0;
	 m1_oper1_wdata <= 0;
	 m1_oper1_we <= 0;
	 m1_coef_waddr <= 0;
	 m1_coef_raddr <= 0;
	 m1_coef_wdata <= 0;
	 m1_coef_we <= 0;
	 lint_RDATA <= 32'hffffffff;
//	 PSLVERR <= 0;
//	 PREADY <= 0;
	 m0_m0_clken <= 0;
	 m0_m1_clken <= 0;
	 m1_m0_clken <= 0;
	 m1_m1_clken <= 0;

      end // if (RESET[0] == 0)
      else begin
         saved_REQ <= lint_REQ;
	 m0_m0_clken <= 0;
	 m0_m1_clken <= 0;
	 m1_m0_clken <= 0;
	 m1_m1_clken <= 0;
	 if (tcdm_gnt_p0)
	   tcdm_req_p0 <= 0;
	 if (tcdm_gnt_p1)
	   tcdm_req_p1 <= 0;
	 if (tcdm_gnt_p2)
	   tcdm_req_p2 <= 0;
	 if (tcdm_gnt_p3)
	   tcdm_req_p3 <= 0;
	 
	 if (tcdm_valid_p0)
	   tcdm_result_p0 <= tcdm_rdata_p0;
	 if (tcdm_valid_p1)
	   tcdm_result_p1 <= tcdm_rdata_p1;
	 if (tcdm_valid_p2)
	   tcdm_result_p2 <= tcdm_rdata_p2;
	 if (tcdm_valid_p3)
	   tcdm_result_p3 <= tcdm_rdata_p3;
	 
	 case (apb_fsm)
	   IDLE: begin
              lint_GNT <= 0;
              lint_VALID <= lint_GNT;
              
//	      PREADY <= 0;
//	      PSLVERR <= 0;
                            
	      if (lint_REQ & !lint_GNT) begin
                 if (lint_WEN == 0) begin
                    lint_GNT <= 1;
                    apb_fsm <= WRITE;
                 end
                 else begin
		    apb_fsm <= READ;
		    case (lint_ADDR[19:12])
		      8'h01: m0_oper0_raddr <= lint_ADDR[11:0];
		      8'h02: m0_oper1_raddr <= lint_ADDR[11:0];
		      8'h03: m0_coef_raddr <= lint_ADDR[11:0];
		      8'h04: m1_oper0_raddr <= lint_ADDR[11:0];
		      8'h05: m1_oper1_raddr <= lint_ADDR[11:0];
		      8'h06: m1_coef_raddr <= lint_ADDR[11:0];
		    endcase // case lint_ADDR
                 end // else: !if(lint_WEN)
              end // if (lint_REQ)
           end // case: IDLE
           

/*
	   ENABLE: begin
	      if (PWRITE)
		apb_fsm <= WRITE;
	      else begin
		 apb_fsm <= READ;
		 case (PADDR[19:12])
		   8'h01: m0_oper0_raddr <= PADDR[11:0];
		   8'h02: m0_oper1_raddr <= PADDR[11:0];
		   8'h03: m0_coef_raddr <= PADDR[11:0];
		   8'h04: m1_oper0_raddr <= PADDR[11:0];
		   8'h05: m1_oper1_raddr <= PADDR[11:0];
		   8'h06: m1_coef_raddr <= PADDR[11:0];
		 endcase // case PADDR[19
	      end // else: !if(PWRITE)
	   end
 */
	   WRITE: begin
	      lint_VALID <= lint_GNT;
              lint_GNT <= 0;
	      apb_fsm <= IDLE;
	      
	      casex (lint_ADDR)
		20'h0: begin 
		   tcdm_addr_p0 <= lint_WDATA[19:0];
		   tcdm_we_p0 <= lint_WDATA[31];
		   tcdm_be_p0 <= lint_BE;
		end
		20'h4: begin 
		   tcdm_addr_p1 <= lint_WDATA[19:0];
		   tcdm_we_p1 <= lint_WDATA[31];
		   tcdm_be_p1 <= lint_BE;
		end
		20'h8: begin
		   tcdm_addr_p2 <= lint_WDATA[19:0];
		   tcdm_we_p2 <= lint_WDATA[31];
		   tcdm_be_p2 <= lint_BE;		 
		end
		20'hc: begin 
		   tcdm_addr_p3 <= lint_WDATA[19:0];
		   tcdm_we_p3 <= lint_WDATA[31];
		   tcdm_be_p3 <= lint_BE;
		end
		20'h80: tcdm_wdata_p0 <= lint_WDATA;
		20'h84: tcdm_wdata_p1 <= lint_WDATA;
		20'h88: tcdm_wdata_p2 <= lint_WDATA;
		20'h8c: tcdm_wdata_p3 <= lint_WDATA;
		20'h10: m0_m0_control <= lint_WDATA;
		20'h14: m0_m1_control <= lint_WDATA;
		20'h18: m1_m0_control <= lint_WDATA;
		20'h1c: m1_m1_control <= lint_WDATA;
		20'h20: m0_ram_control <= lint_WDATA;
		20'h24: m1_ram_control <= lint_WDATA;
		20'h30: m0_m0_clken <= 1;
		20'h34: m0_m1_clken <= 1;
		20'h38: m1_m0_clken <= 1;
		20'h3C: m1_m1_clken <= 1;
		20'h40: ifpga_out[31:0] <= lint_WDATA;
		20'h44: ifpga_out[63:32] <= lint_WDATA;
		20'h48: ifpga_out[79:64] <= lint_WDATA[15:0];
		20'h50: ifpga_oe[31:0] <= lint_WDATA;
		20'h54: ifpga_oe[63:32] <= lint_WDATA;
		20'h58: ifpga_oe[79:64] <= lint_WDATA[15:0];
		20'h6c: i_events <= lint_WDATA[15:0];

		20'h90: tcdm_req_p0 <= 1;
		20'h94: tcdm_req_p1 <= 1;
		20'h98: tcdm_req_p2 <= 1;
		20'h9c: tcdm_req_p3 <= 1;
//		20'h100: PSLVERR <= 1;
		
 		20'b0000_0001_xxxx_xxxx_xxxx:  begin // m0_oper0_ram
		   m0_oper0_waddr <= lint_ADDR[11:0];
		   m0_oper0_we <= 1'b1;
		   m0_oper0_wdata <= lint_WDATA;
		end
		
		20'b0000_0010_xxxx_xxxx_xxxx:  begin // m0_oper1_ram
		   m0_oper1_waddr <= lint_ADDR[11:0];
		   m0_oper1_we <= 1'b1;
		   m0_oper1_wdata <= lint_WDATA;
		end

		20'b0000_0011_xxxx_xxxx_xxxx:  begin // m0_coef_ram
		   m0_coef_waddr <= lint_ADDR[11:0];
		   m0_coef_we <= 1'b1;
		   m0_coef_wdata <= lint_WDATA;
		end
		
		20'b0000_0100_xxxx_xxxx_xxxx:  begin // m1_oper0_ram
		   m1_oper0_waddr <= lint_ADDR[11:0];
		   m1_oper0_we <= 1'b1;
		   m1_oper0_wdata <= lint_WDATA;
		end
		
		20'b0000_0101_xxxx_xxxx_xxxx:  begin // m1_oper1_ram
		   m1_oper1_waddr <= lint_ADDR[11:0];
		   m1_oper1_we <= 1'b1;
		   m1_oper1_wdata <= lint_WDATA;
		end
		20'b0000_0110_xxxx_xxxx_xxxx:  begin // m1_coef_ram
		   m1_coef_waddr <= lint_ADDR[11:0];
		   m1_coef_we <= 1'b1;
		   m1_coef_wdata <= lint_WDATA;
		end

	      endcase // case (lint_ADDR)
	   end
	   READ: begin
	      apb_fsm <= READ_WAIT;
	      casex (lint_ADDR)
		20'h0: lint_RDATA <= tcdm_rdata_p0;
		20'h4: lint_RDATA <= tcdm_rdata_p1;
		20'h8: lint_RDATA <= tcdm_rdata_p2;
		20'hc: lint_RDATA <= tcdm_rdata_p3;
		
		20'h10: lint_RDATA <= m0_m0_control;
		20'h14: lint_RDATA <= m0_m1_control;
		20'h18: lint_RDATA <= m1_m0_control;
		20'h1c: lint_RDATA <= m1_m1_control;
		20'h20: lint_RDATA <= m0_ram_control;
		20'h24: lint_RDATA <= m1_ram_control;
		
		20'h40: lint_RDATA <= ifpga_out[31:0] ;
		20'h44: lint_RDATA <= ifpga_out[63:32];
		20'h48: lint_RDATA <= {16'b0,ifpga_out[79:64]};
		20'h50: lint_RDATA <= ifpga_oe[31:0];
		20'h54: lint_RDATA <= ifpga_oe[63:32];
		20'h58: lint_RDATA <= ifpga_oe[79:64];
		20'h60: lint_RDATA <= fpgaio_in[31:0];
		20'h64: lint_RDATA <= fpgaio_in[63:32];
		20'h68: lint_RDATA <= {saved_REQ,
                                       cnt5,cnt4,cnt3,cnt2,cnt1,fpgaio_in[79:64]};
		20'h6C: lint_RDATA <= {16'b0,i_events};

		20'h80: lint_RDATA <= tcdm_result_p0;
				20'h84: lint_RDATA <= tcdm_result_p1;
				20'h88: lint_RDATA <= tcdm_result_p2;
				20'h8C: lint_RDATA <= tcdm_result_p3;
		
		
		20'h100: lint_RDATA <= m0_m0_dataout;
		20'h104: lint_RDATA <= m0_m1_dataout;
		20'h108: lint_RDATA <= m1_m0_dataout;
		20'h10C: lint_RDATA <= m1_m1_dataout;
		20'h800: lint_RDATA <= 32'hca11ef3a;
                
		
		20'b0000_0001_xxxx_xxxx_xxxx, 20'b0000_0010_xxxx_xxxx_xxxx, 20'b0000_0011_xxxx_xxxx_xxxx,
		  20'b0000_0100_xxxx_xxxx_xxxx, 20'b0000_0101_xxxx_xxxx_xxxx, 20'b0000_0110_xxxx_xxxx_xxxx:
		    apb_fsm <= READ_WAIT;

	      endcase // case (lint_ADDR)
	   end
	   READ_WAIT: begin
	      lint_GNT <= 1;
	      apb_fsm <= IDLE;
	      casex (lint_ADDR)
		20'b0000_0001_xxxx_xxxx_xxxx:
		  lint_RDATA <= m0_oper0_rdata;
		20'b0000_0010_xxxx_xxxx_xxxx:
		  lint_RDATA <= m0_oper1_rdata;
       		20'b0000_0011_xxxx_xxxx_xxxx:
		  lint_RDATA <= m0_coef_rdata;
		20'b0000_0100_xxxx_xxxx_xxxx:
		  lint_RDATA <= m1_oper0_rdata;
		20'b0000_0101_xxxx_xxxx_xxxx:
		  lint_RDATA <= m1_oper1_rdata;
		20'b0000_0110_xxxx_xxxx_xxxx:
		  lint_RDATA <= m1_coef_rdata;
		default: lint_RDATA <= lint_RDATA;
	      endcase // casex (lint_ADDR)
	   end // case: READ_WAIT
           default: apb_fsm <= IDLE;
           
	 endcase // case (apb_fsm)
      end // else: !if(RESET[0] == 0)
   end // always @ (posedge CLK[0] or negedge RESET[0])
   
   
   
   
endmodule // 




