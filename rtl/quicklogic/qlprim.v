/***************************************************
 Vendor        : QuickLogic Corp.
 File Name     : qlprim.v
 Description   : Behavioral model of Logic cell
 Revisions     : Added specify blocks for Logic cell, GPIO and RAM
 Author        : Kishor
*****************************************************/

// logic cell ------------------------------------------------------------------
`timescale 1ns/10ps

////////////////   Implementation of the LUT   //////////////////////
module LUT (fragBitInfo, 
            I0, 
            I1, 
            I2, 
            I3, 
            LUTOutput,
			CarryOut 
			);

input [15:0] fragBitInfo; 
input I0, I1, I2, I3;
output LUTOutput; 
output CarryOut;

wire stage0_op0, stage0_op1, stage0_op2, stage0_op3, stage0_op4, stage0_op5, stage0_op6, stage0_op7; 
wire stage1_op0, stage1_op1, stage1_op2, stage1_op3;
wire stage2_op0, stage2_op1;

//wire carry_mux_op;

//assign carry_mux_op = CIS ? I2 : Cin;

assign stage0_op0 = I0 ? fragBitInfo[1] : fragBitInfo[0];
assign stage0_op1 = I0 ? fragBitInfo[3] : fragBitInfo[2];
assign stage0_op2 = I0 ? fragBitInfo[5] : fragBitInfo[4];
assign stage0_op3 = I0 ? fragBitInfo[7] : fragBitInfo[6];
assign stage0_op4 = I0 ? fragBitInfo[9] : fragBitInfo[8];
assign stage0_op5 = I0 ? fragBitInfo[11] : fragBitInfo[10];
assign stage0_op6 = I0 ? fragBitInfo[13] : fragBitInfo[12];
assign stage0_op7 = I0 ? fragBitInfo[15] : fragBitInfo[14];


assign stage1_op0 = I1 ? stage0_op1 : stage0_op0; 
assign stage1_op1 = I1 ? stage0_op3 : stage0_op2;
assign stage1_op2 = I1 ? stage0_op5 : stage0_op4;
assign stage1_op3 = I1 ? stage0_op7 : stage0_op6;


assign stage2_op0 = I2 ? stage1_op1 : stage1_op0;
assign stage2_op1 = I2 ? stage1_op3 : stage1_op2;


assign LUTOutput = I3 ? stage2_op1 : stage2_op0;
assign CarryOut = stage2_op1;

endmodule


module ONE_LOGIC_CELL (
		tFragBitInfo,
		bFragBitInfo,
        TI0,
        TI1,
        TI2, 
        TI3,
        BI0, 
        BI1,
        BI2,
        BI3,
        TBS, 
        QDI,
        CDS,
        QEN,
        QST,
        QRT,
        QCK,
        QCKS,
        CZ,
        QZ,
        BZ,
        BCO,
		TCO);

input [15:0] tFragBitInfo;
input [15:0] bFragBitInfo;
input TI0, TI1, TI2, TI3, BI0, BI1, BI2, BI3, TBS, QDI, CDS, QEN, QST, QRT, QCK, QCKS;

output  CZ, QZ, BZ, BCO, TCO;


wire tFragLUTOutput, bFragLUTOutput;

wire mux_tbs_op, mux_cds_op, mux_bqs_op; 

reg QZ_reg;


LUT tLUT (.fragBitInfo(tFragBitInfo), .I0(TI0), .I1(TI1), .I2(TI2), .I3(TI3), .LUTOutput(tFragLUTOutput), .CarryOut(TCO));
LUT bLUT (.fragBitInfo(bFragBitInfo), .I0(BI0), .I1(BI1), .I2(BI2), .I3(BI3), .LUTOutput(bFragLUTOutput), .CarryOut(BCO));


assign mux_tbs_op = TBS ? bFragLUTOutput : tFragLUTOutput;
assign mux_cds_op = CDS ? QDI : mux_tbs_op;


always @ (posedge QCK)   
begin
	if(~QRT && ~QST )
		if(QEN)
        	QZ_reg = mux_cds_op;
end
	
always @(QRT or QST)
begin
	if(QRT)
		 QZ_reg = 1'b0;
	else if (QST)
		 QZ_reg = 1'b1;
end


assign CZ = mux_tbs_op; 
assign BZ = bFragLUTOutput;

assign QZ = QZ_reg;
//assign BQZ = mux_bqs_op;

endmodule 


module LOGIC_0 (
		tFragBitInfo,
		bFragBitInfo,
        T0I0,
        T0I1,
        T0I2, 
        T0I3,
        B0I0, 
        B0I1,
        B0I2,
        B0I3,
        TB0S, 
        Q0DI,
        CD0S,
        Q0EN,
        QST,
        QRT,
        QCK,
        QCKS,
        C0Z,
        Q0Z,
        B0Z,
        B0CO,
		T0CO);

input [15:0] tFragBitInfo;
input [15:0] bFragBitInfo;
input T0I0, T0I1, T0I2, T0I3, B0I0, B0I1, B0I2, B0I3, TB0S, Q0DI, CD0S, Q0EN, QST, QRT, QCK, QCKS;

output  C0Z, Q0Z, B0Z, B0CO, T0CO;


wire tFragLUTOutput, bFragLUTOutput;

wire mux_tbs_op, mux_cds_op, mux_bqs_op; 

reg QZ_reg;
reg setupHoldViolation;


LUT tLUT (.fragBitInfo(tFragBitInfo), .I0(T0I0), .I1(T0I1), .I2(T0I2), .I3(T0I3), .LUTOutput(tFragLUTOutput), .CarryOut(T0CO));
LUT bLUT (.fragBitInfo(bFragBitInfo), .I0(B0I0), .I1(B0I1), .I2(B0I2), .I3(B0I3), .LUTOutput(bFragLUTOutput), .CarryOut(B0CO));


assign mux_tbs_op = TB0S ? bFragLUTOutput : tFragLUTOutput;
assign mux_cds_op = CD0S ? Q0DI : mux_tbs_op;

initial
begin
    QZ_reg=1'bx;
    setupHoldViolation = 1'b0;
end

always @ (posedge QCK)   
begin
	if(~QRT && ~QST )
		if(Q0EN)
        	QZ_reg = mux_cds_op;
end
	
always @(QRT or QST)
begin
	if(QRT)
		 QZ_reg = 1'b0;
	else if (QST)
		 QZ_reg = 1'b1;
end

assign Q0Z = setupHoldViolation ? 1'bx : QZ_reg;

reg notifier;
always @(notifier)
begin
    setupHoldViolation = 1'b1;
end


assign C0Z = mux_tbs_op; 
assign B0Z = bFragLUTOutput;

//assign Q0Z = QZ_reg;
//assign BQZ = mux_bqs_op;

wire TB0S_EQ_1_AN_CD0S_EQ_0 = (TB0S == 1'b1 &&  CD0S == 1'b0);
wire CD0S_EQ_1 = (CD0S == 1'b1);
wire Q0EN_EQ_1 = (Q0EN == 1'b1);
wire TB0S_EQ_0_AN_CD0S_EQ_0 = (TB0S == 1'b0 &&  CD0S == 1'b0);
wire CD0S_EQ_0 = (CD0S == 1'b0);

specify
	(TB0S => C0Z) = (0,0);
	(B0I0 => B0CO) = (0,0);
	(B0I1 => B0CO) = (0,0);
	(B0I2 => B0CO) = (0,0);

	(T0I0 => T0CO) = (0,0);
	(T0I1 => T0CO) = (0,0);
	(T0I2 => T0CO) = (0,0);

	if (Q0EN == 1'b1)
	    (QCK => Q0Z)  = (0,0);

	(B0I0 => B0Z) = (0,0);
	(B0I1 => B0Z) = (0,0);
	(B0I3 => B0Z) = (0,0);
	(B0I2 => B0Z) = (0,0);

	if (TB0S == 1'b1)
		(B0I0 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I1 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I3 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I2 => C0Z) = (0,0);

	if (TB0S == 1'b0)
		(T0I0 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I1 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I3 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I2 => C0Z) = (0,0);

$recovery (posedge QRT, posedge QCK &&& Q0EN_EQ_1, 0, notifier);
$recovery (negedge QRT, posedge QCK &&& Q0EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q0EN_EQ_1, 0, notifier);
$removal (negedge QST, posedge QCK &&& Q0EN_EQ_1, 0);

$setup( posedge Q0DI, posedge QCK &&& CD0S_EQ_1, 0, notifier);
$setup( negedge Q0DI, posedge QCK &&& CD0S_EQ_1, 0);
$hold( posedge QCK, posedge Q0DI &&& CD0S_EQ_1, 0, notifier);
$hold( posedge QCK, negedge Q0DI &&& CD0S_EQ_1, 0);

$setup( posedge Q0EN, posedge QCK, 0);
$setup( negedge Q0EN, posedge QCK, 0, notifier);
$hold( posedge QCK, posedge Q0EN, 0);
$hold( posedge QCK, negedge Q0EN, 0, notifier);

$setup( posedge B0I0, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge B0I0, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B0I0 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B0I0 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge B0I1, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge B0I1, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B0I1 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B0I1 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge B0I2, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge B0I2, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B0I2 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B0I2 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge B0I3, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge B0I3, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B0I3 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B0I3 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge T0I0, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge T0I0, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T0I0 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T0I0 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge T0I1, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge T0I1, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T0I1 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T0I1 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge T0I2, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge T0I2, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T0I2 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T0I2 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge T0I3, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$setup( negedge T0I3, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T0I3 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T0I3 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0, notifier);

$setup( posedge TB0S, posedge QCK &&& CD0S_EQ_0, 0, notifier);
$setup( negedge TB0S, posedge QCK &&& CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge TB0S &&& CD0S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge TB0S &&& CD0S_EQ_0, 0, notifier);


endspecify

endmodule 


module LOGIC_1 (
		tFragBitInfo,
		bFragBitInfo,
        T1I0,
        T1I1,
        T1I2, 
        T1I3,
        B1I0, 
        B1I1,
        B1I2,
        B1I3,
        TB1S, 
        Q1DI,
        CD1S,
        Q1EN,
        QST,
        QRT,
        QCK,
        C1Z,
        Q1Z,
        B1Z,
        B1CO,
		T1CO);

input [15:0] tFragBitInfo;
input [15:0] bFragBitInfo;
input T1I0, T1I1, T1I2, T1I3, B1I0, B1I1, B1I2, B1I3, TB1S, Q1DI, CD1S, Q1EN, QST, QRT, QCK;

output  C1Z, Q1Z, B1Z, B1CO, T1CO;


wire tFragLUTOutput, bFragLUTOutput;

wire mux_tbs_op, mux_cds_op, mux_bqs_op; 

reg QZ_reg;
reg setupHoldViolation;


LUT tLUT (.fragBitInfo(tFragBitInfo), .I0(T1I0), .I1(T1I1), .I2(T1I2), .I3(T1I3), .LUTOutput(tFragLUTOutput), .CarryOut(T1CO));
LUT bLUT (.fragBitInfo(bFragBitInfo), .I0(B1I0), .I1(B1I1), .I2(B1I2), .I3(B1I3), .LUTOutput(bFragLUTOutput), .CarryOut(B1CO));


assign mux_tbs_op = TB1S ? bFragLUTOutput : tFragLUTOutput;
assign mux_cds_op = CD1S ? Q1DI : mux_tbs_op;

initial
begin
    QZ_reg=1'bx;
    setupHoldViolation = 1'b0;
end


always @ (posedge QCK)   
begin
	if(~QRT && ~QST )
		if(Q1EN)
        	QZ_reg = mux_cds_op;
end
	
always @(QRT or QST)
begin
	if(QRT)
		 QZ_reg = 1'b0;
	else if (QST)
		 QZ_reg = 1'b1;
end


assign C1Z = mux_tbs_op; 
assign B1Z = bFragLUTOutput;

//assign Q1Z = QZ_reg;
assign Q1Z = setupHoldViolation ? 1'bx : QZ_reg;

reg notifier;
always @(notifier)
begin
    setupHoldViolation = 1'b1;
end


//assign BQZ = mux_bqs_op;

wire TB1S_EQ_1_AN_CD1S_EQ_0 = (TB1S == 1'b1 &&  CD1S == 1'b0);
wire CD1S_EQ_1 = (CD1S == 1'b1);
wire Q1EN_EQ_1 = (Q1EN == 1'b1);
wire TB1S_EQ_0_AN_CD1S_EQ_0 = (TB1S == 1'b0 &&  CD1S == 1'b0);
wire CD1S_EQ_0 = (CD1S == 1'b0);


specify

	(TB1S => C1Z) = (0,0);

	(B1I0 => B1CO) = (0,0);
	(B1I1 => B1CO) = (0,0);
	(B1I2 => B1CO) = (0,0);

	(T1I0 => T1CO) = (0,0);
	(T1I1 => T1CO) = (0,0);
	(T1I2 => T1CO) = (0,0);

	if (Q1EN == 1'b1)
	    (QCK => Q1Z)  = (0,0);

	(B1I0 => B1Z) = (0,0);
	(B1I1 => B1Z) = (0,0);
	(B1I3 => B1Z) = (0,0);
	(B1I2 => B1Z) = (0,0);

	if (TB1S == 1'b1)
		(B1I0 => C1Z) = (0,0);
	if (TB1S == 1'b1)
		(B1I1 => C1Z) = (0,0);
	if (TB1S == 1'b1)
		(B1I3 => C1Z) = (0,0);
	if (TB1S == 1'b1) 
		(B1I2 => C1Z) = (0,0);

	if (TB1S == 1'b0)
		(T1I0 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I1 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I3 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I2 => C1Z) = (0,0);

$recovery (posedge QRT, posedge QCK &&& Q1EN_EQ_1, 0, notifier);
$recovery (negedge QRT, posedge QCK &&& Q1EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q1EN_EQ_1, 0, notifier);
$removal (negedge QST, posedge QCK &&& Q1EN_EQ_1, 0);

$setup( posedge Q1DI, posedge QCK &&& CD1S_EQ_1, 0, notifier);
$setup( negedge Q1DI, posedge QCK &&& CD1S_EQ_1, 0);
$hold( posedge QCK, posedge Q1DI &&& CD1S_EQ_1, 0, notifier);
$hold( posedge QCK, negedge Q1DI &&& CD1S_EQ_1, 0);

$setup( posedge Q1EN, posedge QCK, 0);
$setup( negedge Q1EN, posedge QCK, 0, notifier);
$hold( posedge QCK, posedge Q1EN, 0);
$hold( posedge QCK, negedge Q1EN, 0, notifier);

$setup( posedge B1I0, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge B1I0, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B1I0 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B1I0 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge B1I1, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge B1I1, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B1I1 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B1I1 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge B1I2, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge B1I2, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B1I2 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B1I2 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge B1I3, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge B1I3, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B1I3 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B1I3 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge T1I0, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge T1I0, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T1I0 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T1I0 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge T1I1, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge T1I1, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T1I1 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T1I1 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge T1I2, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge T1I2, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T1I2 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T1I2 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge T1I3, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$setup( negedge T1I3, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T1I3 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T1I3 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0, notifier);

$setup( posedge TB1S, posedge QCK &&& CD1S_EQ_0, 0, notifier);
$setup( negedge TB1S, posedge QCK &&& CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge TB1S &&& CD1S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge TB1S &&& CD1S_EQ_0, 0, notifier);

endspecify

endmodule 


module LOGIC_2 (
		tFragBitInfo,
		bFragBitInfo,
        T2I0,
        T2I1,
        T2I2, 
        T2I3,
        B2I0, 
        B2I1,
        B2I2,
        B2I3,
        TB2S, 
        Q2DI,
        CD2S,
        Q2EN,
        QST,
        QRT,
        QCK,
        C2Z,
        Q2Z,
        B2Z,
        B2CO,
		T2CO);

input [15:0] tFragBitInfo;
input [15:0] bFragBitInfo;
input T2I0, T2I1, T2I2, T2I3, B2I0, B2I1, B2I2, B2I3, TB2S, Q2DI, CD2S, Q2EN, QST, QRT, QCK;

output  C2Z, Q2Z, B2Z, B2CO, T2CO;


wire tFragLUTOutput, bFragLUTOutput;

wire mux_tbs_op, mux_cds_op, mux_bqs_op; 

reg QZ_reg;
reg setupHoldViolation;

initial
begin
    QZ_reg=1'bx;
    setupHoldViolation = 1'b0;
end



LUT tLUT (.fragBitInfo(tFragBitInfo), .I0(T2I0), .I1(T2I1), .I2(T2I2), .I3(T2I3), .LUTOutput(tFragLUTOutput), .CarryOut(T2CO));
LUT bLUT (.fragBitInfo(bFragBitInfo), .I0(B2I0), .I1(B2I1), .I2(B2I2), .I3(B2I3), .LUTOutput(bFragLUTOutput), .CarryOut(B2CO));


assign mux_tbs_op = TB2S ? bFragLUTOutput : tFragLUTOutput;
assign mux_cds_op = CD2S ? Q2DI : mux_tbs_op;


always @ (posedge QCK)   
begin
	if(~QRT && ~QST )
		if(Q2EN)
        	QZ_reg = mux_cds_op;
end
	
always @(QRT or QST)
begin
	if(QRT)
		 QZ_reg = 1'b0;
	else if (QST)
		 QZ_reg = 1'b1;
end


assign C2Z = mux_tbs_op; 
assign B2Z = bFragLUTOutput;

//assign Q2Z = QZ_reg;
assign Q2Z = setupHoldViolation ? 1'bx : QZ_reg;

reg notifier;
always @(notifier)
begin
    setupHoldViolation = 1'b1;
end

//assign BQZ = mux_bqs_op;

wire TB2S_EQ_1_AN_CD2S_EQ_0 = (TB2S == 1'b1 &&  CD2S == 1'b0);
wire CD2S_EQ_1 = (CD2S == 1'b1);
wire Q2EN_EQ_1 = (Q2EN == 1'b1);
wire TB2S_EQ_0_AN_CD2S_EQ_0 = (TB2S == 1'b0 &&  CD2S == 1'b0);
wire CD2S_EQ_0 = (CD2S == 1'b0);

specify

	(TB2S => C2Z) = (0,0);

	(B2I0 => B2CO) = (0,0);
	(B2I1 => B2CO) = (0,0);
	(B2I2 => B2CO) = (0,0);

	(T2I0 => T2CO) = (0,0);
	(T2I1 => T2CO) = (0,0);
	(T2I2 => T2CO) = (0,0);

	if (Q2EN == 1'b1)
	    (QCK => Q2Z)  = (0,0);

	(B2I0 => B2Z) = (0,0);
	(B2I1 => B2Z) = (0,0);
	(B2I3 => B2Z) = (0,0);
	(B2I2 => B2Z) = (0,0);

	if (TB2S == 1'b1)
		(B2I0 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I1 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I3 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I2 => C2Z) = (0,0);

	if (TB2S == 1'b0)
		(T2I0 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I1 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I3 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I2 => C2Z) = (0,0);

$recovery (posedge QRT, posedge QCK &&& Q2EN_EQ_1, 0, notifier);
$recovery (negedge QRT, posedge QCK &&& Q2EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q2EN_EQ_1, 0, notifier);
$removal (negedge QST, posedge QCK &&& Q2EN_EQ_1, 0);

$setup( posedge Q2DI, posedge QCK &&& CD2S_EQ_1, 0, notifier);
$setup( negedge Q2DI, posedge QCK &&& CD2S_EQ_1, 0);
$hold( posedge QCK, posedge Q2DI &&& CD2S_EQ_1, 0, notifier);
$hold( posedge QCK, negedge Q2DI &&& CD2S_EQ_1, 0);

$setup( posedge Q2EN, posedge QCK, 0);
$setup( negedge Q2EN, posedge QCK, 0, notifier);
$hold( posedge QCK, posedge Q2EN, 0);
$hold( posedge QCK, negedge Q2EN, 0, notifier);

$setup( posedge B2I0, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge B2I0, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B2I0 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B2I0 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge B2I1, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge B2I1, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B2I1 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B2I1 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge B2I2, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge B2I2, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B2I2 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B2I2 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge B2I3, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge B2I3, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B2I3 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B2I3 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge T2I0, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge T2I0, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T2I0 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T2I0 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge T2I1, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge T2I1, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T2I1 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T2I1 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge T2I2, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge T2I2, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T2I2 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T2I2 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge T2I3, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$setup( negedge T2I3, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T2I3 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T2I3 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0, notifier);

$setup( posedge TB2S, posedge QCK &&& CD2S_EQ_0, 0, notifier);
$setup( negedge TB2S, posedge QCK &&& CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge TB2S &&& CD2S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge TB2S &&& CD2S_EQ_0, 0, notifier);

endspecify

endmodule 


module LOGIC_3 (
		tFragBitInfo,
		bFragBitInfo,
        T3I0,
        T3I1,
        T3I2, 
        T3I3,
        B3I0, 
        B3I1,
        B3I2,
        B3I3,
        TB3S, 
        Q3DI,
        CD3S,
        Q3EN,
        QST,
        QRT,
        QCK,
        C3Z,
        Q3Z,
        B3Z,
        B3CO,
		T3CO);

input [15:0] tFragBitInfo;
input [15:0] bFragBitInfo;
input T3I0, T3I1, T3I2, T3I3, B3I0, B3I1, B3I2, B3I3, TB3S, Q3DI, CD3S, Q3EN, QST, QRT, QCK;

output  C3Z, Q3Z, B3Z, B3CO, T3CO;


wire tFragLUTOutput, bFragLUTOutput;

wire mux_tbs_op, mux_cds_op, mux_bqs_op; 

reg QZ_reg;
reg setupHoldViolation;


LUT tLUT (.fragBitInfo(tFragBitInfo), .I0(T3I0), .I1(T3I1), .I2(T3I2), .I3(T3I3), .LUTOutput(tFragLUTOutput), .CarryOut(T3CO));
LUT bLUT (.fragBitInfo(bFragBitInfo), .I0(B3I0), .I1(B3I1), .I2(B3I2), .I3(B3I3), .LUTOutput(bFragLUTOutput), .CarryOut(B3CO));


assign mux_tbs_op = TB3S ? bFragLUTOutput : tFragLUTOutput;
assign mux_cds_op = CD3S ? Q3DI : mux_tbs_op;

initial
begin
    QZ_reg=1'bx;
    setupHoldViolation = 1'b0;
end

always @ (posedge QCK)   
begin
	if(~QRT && ~QST )
		if(Q3EN)
        	QZ_reg = mux_cds_op;
end
	
always @(QRT or QST)
begin
	if(QRT)
		 QZ_reg = 1'b0;
	else if (QST)
		 QZ_reg = 1'b1;
end


assign C3Z = mux_tbs_op; 
assign B3Z = bFragLUTOutput;

//assign Q3Z = QZ_reg;
assign Q3Z = setupHoldViolation ? 1'bx : QZ_reg;

reg notifier;
always @(notifier)
begin
    setupHoldViolation = 1'b1;
end


//assign BQZ = mux_bqs_op;

wire TB3S_EQ_1_AN_CD3S_EQ_0 = (TB3S == 1'b1 &&  CD3S == 1'b0);
wire CD3S_EQ_1 = (CD3S == 1'b1);
wire Q3EN_EQ_1 = (Q3EN == 1'b1);
wire TB3S_EQ_0_AN_CD3S_EQ_0 = (TB3S == 1'b0 &&  CD3S == 1'b0);
wire CD3S_EQ_0 = (CD3S == 1'b0);

specify

	(TB3S => C3Z) = (0,0);

	(T3I0 => T3CO) = (0,0);
	(T3I1 => T3CO) = (0,0);
	(T3I2 => T3CO) = (0,0);

	if (Q3EN == 1'b1)
	    (QCK => Q3Z)  = (0,0);

	(B3I0 => B3CO) = (0,0);
	(B3I1 => B3CO) = (0,0);
	//(B3I3 => B3CO) = (0,0);
	(B3I2 => B3CO) = (0,0);

	(B3I0 => B3Z) = (0,0);
	(B3I1 => B3Z) = (0,0);
	(B3I3 => B3Z) = (0,0);
	(B3I2 => B3Z) = (0,0);

	if (TB3S == 1'b1)
		(B3I0 => C3Z) = (0,0);
	if (TB3S == 1'b1)
		(B3I1 => C3Z) = (0,0);
	if (TB3S == 1'b1)
		(B3I3 => C3Z) = (0,0);
	if (TB3S == 1'b1) 
		(B3I2 => C3Z) = (0,0);

	if (TB3S == 1'b0)
		(T3I0 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I1 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I3 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I2 => C3Z) = (0,0);

$recovery (posedge QRT, posedge QCK &&& Q3EN_EQ_1, 0, notifier);
$recovery (negedge QRT, posedge QCK &&& Q3EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q3EN_EQ_1, 0, notifier);
$removal (negedge QST, posedge QCK &&& Q3EN_EQ_1, 0);

$setup( posedge Q3DI, posedge QCK &&& CD3S_EQ_1, 0, notifier);
$setup( negedge Q3DI, posedge QCK &&& CD3S_EQ_1, 0);
$hold( posedge QCK, posedge Q3DI &&& CD3S_EQ_1, 0, notifier);
$hold( posedge QCK, negedge Q3DI &&& CD3S_EQ_1, 0);

$setup( posedge Q3EN, posedge QCK, 0);
$setup( negedge Q3EN, posedge QCK, 0, notifier);
$hold( posedge QCK, posedge Q3EN, 0);
$hold( posedge QCK, negedge Q3EN, 0, notifier);

$setup( posedge B3I0, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge B3I0, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B3I0 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B3I0 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge B3I1, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge B3I1, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B3I1 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B3I1 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge B3I2, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge B3I2, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B3I2 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B3I2 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge B3I3, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge B3I3, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge B3I3 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge B3I3 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge T3I0, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge T3I0, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T3I0 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T3I0 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge T3I1, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge T3I1, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T3I1 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T3I1 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge T3I2, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge T3I2, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T3I2 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T3I2 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge T3I3, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$setup( negedge T3I3, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge T3I3 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge T3I3 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0, notifier);

$setup( posedge TB3S, posedge QCK &&& CD3S_EQ_0, 0, notifier);
$setup( negedge TB3S, posedge QCK &&& CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, posedge TB3S &&& CD3S_EQ_0, 0, notifier);
$hold( posedge QCK, negedge TB3S &&& CD3S_EQ_0, 0, notifier);


endspecify

endmodule 


module LOGIC (
		tFragBitInfo, 
		bFragBitInfo,
        T0I0, 
        T0I1,
        T0I2,
        T0I3,
        B0I0, 
        B0I1,
        B0I2,
        B0I3,
        TB0S, 
        Q0DI,
        CD0S,
        Q0EN,
        T1I0,
        T1I1,
        T1I2,
        T1I3,
        B1I0, 
        B1I1,
        B1I2,
        B1I3,
        TB1S, 
        Q1DI,
        CD1S,
        Q1EN,
        T2I0,
        T2I1,
        T2I2,
        T2I3,
        B2I0, 
        B2I1,
        B2I2,
        B2I3,
        TB2S, 
        Q2DI,
        CD2S,
        Q2EN,
        T3I0,
        T3I1,
        T3I2,
        T3I3,
        B3I0, 
        B3I1,
        B3I2,
        B3I3,
        TB3S, 
        Q3DI,
        CD3S,
        Q3EN,
        QST, 
        QRT,
        QCK,
        QCKS,
        C0Z,
        Q0Z,
        B0Z,
        C1Z,
        Q1Z,
        B1Z,
        C2Z,
        Q2Z,
        B2Z,
        C3Z,
        Q3Z,
        B3Z,
		T0CO, 
		B0CO, 
        T3CO, 
        B3CO, 
		T1CO, 
		B1CO, 
		T2CO, 
		B2CO);

input [63:0] tFragBitInfo;
input [63:0] bFragBitInfo;
input  T0I0; 
input  T0I1;
input  T0I2;
input  T0I3;
input  B0I0; 
input  B0I1;
input  B0I2;
input  B0I3;
input  TB0S; 
input  Q0DI;
input  CD0S;
input  Q0EN;
input  T1I0;
input  T1I1;
input  T1I2;
input  T1I3;
input  B1I0; 
input  B1I1;
input  B1I2;
input  B1I3;
input  TB1S; 
input  Q1DI;
input  CD1S;
input  Q1EN;
input  T2I0;
input  T2I1;
input  T2I2;
input  T2I3;
input  B2I0; 
input  B2I1;
input  B2I2;
input  B2I3;
input  TB2S; 
input  Q2DI;
input  CD2S;
input  Q2EN;
input  T3I0;
input  T3I1;
input  T3I2;
input  T3I3;
input  B3I0; 
input  B3I1;
input  B3I2;
input  B3I3;
input  TB3S; 
input  Q3DI;
input  CD3S;
input  Q3EN;
input  QST;
input  QRT;
input  QCK;
input  QCKS;
output  C0Z;
output  Q0Z;
output  B0Z;
output  C1Z;
output  Q1Z;
output  B1Z;
output  C2Z;
output  Q2Z;
output  B2Z;
output  C3Z;
output  Q3Z;
output  B3Z;
output  T3CO; 
output  B3CO;
output  T0CO; 
output  B0CO; 
output  T1CO; 
output  B1CO; 
output  T2CO; 	
output  B2CO;


ONE_LOGIC_CELL logic0(
		.tFragBitInfo (tFragBitInfo[15:0]),
		.bFragBitInfo (bFragBitInfo[15:0]),
        .TI0 (T0I0),
        .TI1 (T0I1),
        .TI2 (T0I2), 
        .TI3 (T0I3),
        .BI0 (B0I0), 
        .BI1 (B0I1),
        .BI2 (B0I2),
        .BI3 (B0I3),
        .TBS (TB0S), 
        .QDI (Q0DI),
        .CDS (CD0S),
        .QEN (Q0EN),
        .QST (QST),
        .QRT (QRT),
        .QCK (QCK),
        .QCKS (QCKS),
        .CZ (C0Z),
        .QZ (Q0Z),
        .BZ (B0Z),
        .TCO (T0CO), 
        .BCO (B0CO)); 

ONE_LOGIC_CELL logic1(
		.tFragBitInfo (tFragBitInfo[31:16]),
		.bFragBitInfo (bFragBitInfo[31:16]),
        .TI0 (T1I0),
        .TI1 (T1I1),
        .TI2 (T1I2), 
        .TI3 (T1I3),
        .BI0 (B1I0), 
        .BI1 (B1I1),
        .BI2 (B1I2),
        .BI3 (B1I3),
        .TBS (TB1S), 
        .QDI (Q1DI),
        .CDS (CD1S),
        .QEN (Q1EN),
        .QST (QST),
        .QRT (QRT),
        .QCK (QCK),
        .QCKS (QCKS),
        .CZ (C1Z),
        .QZ (Q1Z),
        .BZ (B1Z),
        .TCO (T1CO), 
        .BCO (B1CO)); 

ONE_LOGIC_CELL logic2(
		.tFragBitInfo (tFragBitInfo[47:32]),
		.bFragBitInfo (bFragBitInfo[47:32]),
        .TI0 (T2I0),
        .TI1 (T2I1),
        .TI2 (T2I2), 
        .TI3 (T2I3),
        .BI0 (B2I0), 
        .BI1 (B2I1),
        .BI2 (B2I2),
        .BI3 (B2I3),
        .TBS (TB2S), 
        .QDI (Q2DI),
        .CDS (CD2S),
        .QEN (Q2EN),
        .QST (QST),
        .QRT (QRT),
        .QCK (QCK),
        .QCKS (QCKS),
        .CZ (C2Z),
        .QZ (Q2Z),
        .BZ (B2Z),
        .TCO (T2CO),
        .BCO (B2CO));

ONE_LOGIC_CELL logic3(
		.tFragBitInfo (tFragBitInfo[63:48]),
		.bFragBitInfo (bFragBitInfo[63:48]),
        .TI0 (T3I0),
        .TI1 (T3I1),
        .TI2 (T3I2), 
        .TI3 (T3I3),
        .BI0 (B3I0), 
        .BI1 (B3I1),
        .BI2 (B3I2),
        .BI3 (B3I3),
        .TBS (TB3S), 
        .QDI (Q3DI),
        .CDS (CD3S),
        .QEN (Q3EN),
        .QST (QST),
        .QRT (QRT),
        .QCK (QCK),
        .QCKS (QCKS),
        .CZ (C3Z),
        .QZ (Q3Z),
        .BZ (B3Z),
        .TCO (T3CO),
        .BCO (B3CO)); 

/***Logic Cell Specify Block Data***/

wire TB0S_EQ_1_AN_CD0S_EQ_0 = (TB0S == 1'b1 &&  CD0S == 1'b0);
wire TB1S_EQ_1_AN_CD1S_EQ_0 = (TB1S == 1'b1 &&  CD1S == 1'b0);
wire TB2S_EQ_1_AN_CD2S_EQ_0 = (TB2S == 1'b1 &&  CD2S == 1'b0);
wire TB3S_EQ_1_AN_CD3S_EQ_0 = (TB3S == 1'b1 &&  CD3S == 1'b0);
wire CD0S_EQ_1 = (CD0S == 1'b1);
wire CD1S_EQ_1 = (CD1S == 1'b1);
wire CD2S_EQ_1 = (CD2S == 1'b1);
wire CD3S_EQ_1 = (CD3S == 1'b1);
wire Q0EN_EQ_1 = (Q0EN == 1'b1);
wire Q1EN_EQ_1 = (Q1EN == 1'b1);
wire Q2EN_EQ_1 = (Q2EN == 1'b1);
wire Q3EN_EQ_1 = (Q3EN == 1'b1);
wire TB0S_EQ_0_AN_CD0S_EQ_0 = (TB0S == 1'b0 &&  CD0S == 1'b0);
wire TB1S_EQ_0_AN_CD1S_EQ_0 = (TB1S == 1'b0 &&  CD1S == 1'b0);
wire TB2S_EQ_0_AN_CD2S_EQ_0 = (TB2S == 1'b0 &&  CD2S == 1'b0);
wire TB3S_EQ_0_AN_CD3S_EQ_0 = (TB3S == 1'b0 &&  CD3S == 1'b0);
wire CD0S_EQ_0 = (CD0S == 1'b0);
wire CD1S_EQ_0 = (CD1S == 1'b0);
wire CD2S_EQ_0 = (CD2S == 1'b0);
wire CD3S_EQ_0 = (CD3S == 1'b0);

specify

	(TB0S => C0Z) = (0,0);
	(TB1S => C1Z) = (0,0);
	(TB2S => C2Z) = (0,0);
	(TB3S => C3Z) = (0,0);

	(B0I0 => B0CO) = (0,0);
	(B0I1 => B0CO) = (0,0);
	(B0I2 => B0CO) = (0,0);

	(B1I0 => B1CO) = (0,0);
	(B1I1 => B1CO) = (0,0);
	(B1I2 => B1CO) = (0,0);

	(B2I0 => B2CO) = (0,0);
	(B2I1 => B2CO) = (0,0);
	(B2I2 => B2CO) = (0,0);

	(T0I0 => T0CO) = (0,0);
	(T0I1 => T0CO) = (0,0);
	(T0I2 => T0CO) = (0,0);

	(T1I0 => T1CO) = (0,0);
	(T1I1 => T1CO) = (0,0);
	(T1I2 => T1CO) = (0,0);

	(T2I0 => T2CO) = (0,0);
	(T2I1 => T2CO) = (0,0);
	(T2I2 => T2CO) = (0,0);

	(T3I0 => T3CO) = (0,0);
	(T3I1 => T3CO) = (0,0);
	(T3I2 => T3CO) = (0,0);

	if (Q0EN == 1'b1)
	    (QCK => Q0Z)  = (0,0);
	if (Q1EN == 1'b1)
	    (QCK => Q1Z)  = (0,0);
	if (Q2EN == 1'b1)
	    (QCK => Q2Z)  = (0,0);
	if (Q3EN == 1'b1)
	    (QCK => Q3Z)  = (0,0);

	(B3I0 => B3CO) = (0,0);
	(B3I1 => B3CO) = (0,0);
	//(B3I3 => B3CO) = (0,0);
	(B3I2 => B3CO) = (0,0);

	(B0I0 => B0Z) = (0,0);
	(B0I1 => B0Z) = (0,0);
	(B0I3 => B0Z) = (0,0);
	(B0I2 => B0Z) = (0,0);

	if (TB0S == 1'b1)
		(B0I0 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I1 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I3 => C0Z) = (0,0);
	if (TB0S == 1'b1)
		(B0I2 => C0Z) = (0,0);

	if (TB0S == 1'b0)
		(T0I0 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I1 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I3 => C0Z) = (0,0);
	if (TB0S == 1'b0)
		(T0I2 => C0Z) = (0,0);

	(B1I0 => B1Z) = (0,0);
	(B1I1 => B1Z) = (0,0);
	(B1I3 => B1Z) = (0,0);
	(B1I2 => B1Z) = (0,0);

	if (TB1S == 1'b1)
		(B1I0 => C1Z) = (0,0);
	if (TB1S == 1'b1)
		(B1I1 => C1Z) = (0,0);
	if (TB1S == 1'b1)
		(B1I3 => C1Z) = (0,0);
	if (TB1S == 1'b1) 
		(B1I2 => C1Z) = (0,0);

	if (TB1S == 1'b0)
		(T1I0 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I1 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I3 => C1Z) = (0,0);
	if (TB1S == 1'b0)
		(T1I2 => C1Z) = (0,0);

	(B2I0 => B2Z) = (0,0);
	(B2I1 => B2Z) = (0,0);
	(B2I3 => B2Z) = (0,0);
	(B2I2 => B2Z) = (0,0);

	if (TB2S == 1'b1)
		(B2I0 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I1 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I3 => C2Z) = (0,0);
	if (TB2S == 1'b1)
		(B2I2 => C2Z) = (0,0);

	if (TB2S == 1'b0)
		(T2I0 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I1 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I3 => C2Z) = (0,0);
	if (TB2S == 1'b0)
		(T2I2 => C2Z) = (0,0);

	(B3I0 => B3Z) = (0,0);
	(B3I1 => B3Z) = (0,0);
	(B3I3 => B3Z) = (0,0);
	(B3I2 => B3Z) = (0,0);

	if (TB3S == 1'b1)
		(B3I0 => C3Z) = (0,0);
	if (TB3S == 1'b1)
		(B3I1 => C3Z) = (0,0);
	if (TB3S == 1'b1)
		(B3I3 => C3Z) = (0,0);
	if (TB3S == 1'b1) 
		(B3I2 => C3Z) = (0,0);

	if (TB3S == 1'b0)
		(T3I0 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I1 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I3 => C3Z) = (0,0);
	if (TB3S == 1'b0)
		(T3I2 => C3Z) = (0,0);

$recovery (posedge QRT, posedge QCK &&& Q0EN_EQ_1, 0);
$recovery (negedge QRT, posedge QCK &&& Q0EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q0EN_EQ_1, 0);
$removal (negedge QST, posedge QCK &&& Q0EN_EQ_1, 0);

$recovery (posedge QRT, posedge QCK &&& Q1EN_EQ_1, 0);
$recovery (negedge QRT, posedge QCK &&& Q1EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q1EN_EQ_1, 0);
$removal (negedge QST, posedge QCK &&& Q1EN_EQ_1, 0);

$recovery (posedge QRT, posedge QCK &&& Q2EN_EQ_1, 0);
$recovery (negedge QRT, posedge QCK &&& Q2EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q2EN_EQ_1, 0);
$removal (negedge QST, posedge QCK &&& Q2EN_EQ_1, 0);

$recovery (posedge QRT, posedge QCK &&& Q3EN_EQ_1, 0);
$recovery (negedge QRT, posedge QCK &&& Q3EN_EQ_1, 0);
$removal (posedge QST, posedge QCK &&& Q3EN_EQ_1, 0);
$removal (negedge QST, posedge QCK &&& Q3EN_EQ_1, 0);

$setup( posedge Q0DI, posedge QCK &&& CD0S_EQ_1, 0);
$setup( negedge Q0DI, posedge QCK &&& CD0S_EQ_1, 0);
$hold( posedge QCK, posedge Q0DI &&& CD0S_EQ_1, 0);
$hold( posedge QCK, negedge Q0DI &&& CD0S_EQ_1, 0);

$setup( posedge Q1DI, posedge QCK &&& CD1S_EQ_1, 0);
$setup( negedge Q1DI, posedge QCK &&& CD1S_EQ_1, 0);
$hold( posedge QCK, posedge Q1DI &&& CD1S_EQ_1, 0);
$hold( posedge QCK, negedge Q1DI &&& CD1S_EQ_1, 0);

$setup( posedge Q2DI, posedge QCK &&& CD2S_EQ_1, 0);
$setup( negedge Q2DI, posedge QCK &&& CD2S_EQ_1, 0);
$hold( posedge QCK, posedge Q2DI &&& CD2S_EQ_1, 0);
$hold( posedge QCK, negedge Q2DI &&& CD2S_EQ_1, 0);

$setup( posedge Q3DI, posedge QCK &&& CD3S_EQ_1, 0);
$setup( negedge Q3DI, posedge QCK &&& CD3S_EQ_1, 0);
$hold( posedge QCK, posedge Q3DI &&& CD3S_EQ_1, 0);
$hold( posedge QCK, negedge Q3DI &&& CD3S_EQ_1, 0);

$setup( posedge Q0EN, posedge QCK, 0);
$setup( negedge Q0EN, posedge QCK, 0);
$hold( posedge QCK, posedge Q0EN, 0);
$hold( posedge QCK, negedge Q0EN, 0);

$setup( posedge Q1EN, posedge QCK, 0);
$setup( negedge Q1EN, posedge QCK, 0);
$hold( posedge QCK, posedge Q1EN, 0);
$hold( posedge QCK, negedge Q1EN, 0);

$setup( posedge Q2EN, posedge QCK, 0);
$setup( negedge Q2EN, posedge QCK, 0);
$hold( posedge QCK, posedge Q2EN, 0);
$hold( posedge QCK, negedge Q2EN, 0);

$setup( posedge Q3EN, posedge QCK, 0);
$setup( negedge Q3EN, posedge QCK, 0);
$hold( posedge QCK, posedge Q3EN, 0);
$hold( posedge QCK, negedge Q3EN, 0);

$setup( posedge B0I0, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$setup( negedge B0I0, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge B0I0 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge B0I0 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);

$setup( posedge B0I1, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$setup( negedge B0I1, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge B0I1 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge B0I1 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);

$setup( posedge B0I2, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$setup( negedge B0I2, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge B0I2 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge B0I2 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);

$setup( posedge B0I3, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$setup( negedge B0I3, posedge QCK &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge B0I3 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge B0I3 &&& TB0S_EQ_1_AN_CD0S_EQ_0, 0);

$setup( posedge B1I0, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$setup( negedge B1I0, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge B1I0 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge B1I0 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);

$setup( posedge B1I1, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$setup( negedge B1I1, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge B1I1 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge B1I1 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);

$setup( posedge B1I2, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$setup( negedge B1I2, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge B1I2 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge B1I2 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);

$setup( posedge B1I3, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$setup( negedge B1I3, posedge QCK &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge B1I3 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge B1I3 &&& TB1S_EQ_1_AN_CD1S_EQ_0, 0);

$setup( posedge B2I0, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$setup( negedge B2I0, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge B2I0 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge B2I0 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);

$setup( posedge B2I1, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$setup( negedge B2I1, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge B2I1 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge B2I1 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);

$setup( posedge B2I2, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$setup( negedge B2I2, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge B2I2 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge B2I2 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);

$setup( posedge B2I3, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$setup( negedge B2I3, posedge QCK &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge B2I3 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge B2I3 &&& TB2S_EQ_1_AN_CD2S_EQ_0, 0);

$setup( posedge B3I0, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$setup( negedge B3I0, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge B3I0 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge B3I0 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);

$setup( posedge B3I1, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$setup( negedge B3I1, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge B3I1 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge B3I1 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);

$setup( posedge B3I2, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$setup( negedge B3I2, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge B3I2 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge B3I2 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);

$setup( posedge B3I3, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$setup( negedge B3I3, posedge QCK &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge B3I3 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge B3I3 &&& TB3S_EQ_1_AN_CD3S_EQ_0, 0);

$setup( posedge T0I0, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$setup( negedge T0I0, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge T0I0 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge T0I0 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);

$setup( posedge T0I1, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$setup( negedge T0I1, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge T0I1 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge T0I1 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);

$setup( posedge T0I2, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$setup( negedge T0I2, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge T0I2 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge T0I2 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);

$setup( posedge T0I3, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$setup( negedge T0I3, posedge QCK &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, posedge T0I3 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);
$hold( posedge QCK, negedge T0I3 &&& TB0S_EQ_0_AN_CD0S_EQ_0, 0);

$setup( posedge T1I0, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$setup( negedge T1I0, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge T1I0 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge T1I0 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);

$setup( posedge T1I1, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$setup( negedge T1I1, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge T1I1 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge T1I1 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);

$setup( posedge T1I2, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$setup( negedge T1I2, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge T1I2 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge T1I2 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);

$setup( posedge T1I3, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$setup( negedge T1I3, posedge QCK &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, posedge T1I3 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);
$hold( posedge QCK, negedge T1I3 &&& TB1S_EQ_0_AN_CD1S_EQ_0, 0);

$setup( posedge T2I0, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$setup( negedge T2I0, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge T2I0 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge T2I0 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);

$setup( posedge T2I1, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$setup( negedge T2I1, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge T2I1 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge T2I1 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);

$setup( posedge T2I2, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$setup( negedge T2I2, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge T2I2 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge T2I2 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);

$setup( posedge T2I3, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$setup( negedge T2I3, posedge QCK &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, posedge T2I3 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);
$hold( posedge QCK, negedge T2I3 &&& TB2S_EQ_0_AN_CD2S_EQ_0, 0);

$setup( posedge T3I0, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$setup( negedge T3I0, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge T3I0 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge T3I0 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);

$setup( posedge T3I1, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$setup( negedge T3I1, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge T3I1 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge T3I1 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);

$setup( posedge T3I2, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$setup( negedge T3I2, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge T3I2 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge T3I2 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);

$setup( posedge T3I3, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$setup( negedge T3I3, posedge QCK &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, posedge T3I3 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);
$hold( posedge QCK, negedge T3I3 &&& TB3S_EQ_0_AN_CD3S_EQ_0, 0);

$setup( posedge TB0S, posedge QCK &&& CD0S_EQ_0, 0);
$setup( negedge TB0S, posedge QCK &&& CD0S_EQ_0, 0);
$hold( posedge QCK, posedge TB0S &&& CD0S_EQ_0, 0);
$hold( posedge QCK, negedge TB0S &&& CD0S_EQ_0, 0);

$setup( posedge TB1S, posedge QCK &&& CD1S_EQ_0, 0);
$setup( negedge TB1S, posedge QCK &&& CD1S_EQ_0, 0);
$hold( posedge QCK, posedge TB1S &&& CD1S_EQ_0, 0);
$hold( posedge QCK, negedge TB1S &&& CD1S_EQ_0, 0);

$setup( posedge TB2S, posedge QCK &&& CD2S_EQ_0, 0);
$setup( negedge TB2S, posedge QCK &&& CD2S_EQ_0, 0);
$hold( posedge QCK, posedge TB2S &&& CD2S_EQ_0, 0);
$hold( posedge QCK, negedge TB2S &&& CD2S_EQ_0, 0);

$setup( posedge TB3S, posedge QCK &&& CD3S_EQ_0, 0);
$setup( negedge TB3S, posedge QCK &&& CD3S_EQ_0, 0);
$hold( posedge QCK, posedge TB3S &&& CD3S_EQ_0, 0);
$hold( posedge QCK, negedge TB3S &&& CD3S_EQ_0, 0);


endspecify


endmodule    


`timescale 1ns/10ps

module BIDIR (	
		ESEL,
		IE,
		OSEL,
		OQI,
		OQE,	
		FIXHOLD,
		IZ,
		IQZ,
		IQE,
		IQC,
		IQR,
		IN_EN,
		IP,
		CLK_EN,
		DS_0_,
		DS_1_,
		SR,
		ST,
		WP_0_,
		WP_1_
		);
				
input ESEL;
input IE;
input OSEL;
input OQI;
input OQE;
input FIXHOLD;
output IZ;
output IQZ;
input IQE;
input IQC;
input IN_EN;
input IQR;
inout IP;

input	CLK_EN;
input	DS_0_;
input	DS_1_;
input	SR;
input	ST;
input	WP_0_;
input	WP_1_;

reg EN_reg, OQ_reg, IQZ;
wire rstn, EN, OQ, AND_OUT, IQCP;

wire FIXHOLD_int;	
wire ESEL_int;
wire IE_int;
wire OSEL_int;
wire OQI_int;
wire IN_EN_int;
wire OQE_int;
wire IQE_int;
wire IQC_int;
wire IQR_int;

parameter IOwithOUTDriver = 0;        //  has to be set for IO with out Driver

buf FIXHOLD_buf (FIXHOLD_int,FIXHOLD);	
//buf IN_EN_buf (INEN_int,INEN);
buf IQC_buf (IQC_int,IQC);
buf IQR_buf (IQR_int,IQR);
buf ESEL_buf (ESEL_int,ESEL);
buf IE_buf (IE_int,IE);
buf OSEL_buf (OSEL_int,OSEL);
buf OQI_buf (OQI_int,OQI);
buf OQE_buf (OQE_int,OQE);
buf IQE_buf (IQE_int,IQE);

assign rstn = ~IQR_int;
assign IQCP = IQC_int;
 if (IOwithOUTDriver)
 begin
	assign IZ = IP;
 end
 else
  begin
	//assign AND_OUT = IN_EN_int ? IP : 1'b0;
	// Changing IN_EN_int, as its functionality is changed now
	assign AND_OUT = ~IN_EN ? IP : 1'b0;

	assign IZ = AND_OUT;
 end
assign EN = ESEL_int ? IE_int : EN_reg ;

assign OQ = OSEL_int ? OQI_int : OQ_reg ;

assign IP = EN ? OQ : 1'bz;

initial
	begin		
		//Power on reset
		EN_reg	= 1'b0;
		OQ_reg= 1'b0;
		IQZ=1'b0;
	end
always @(posedge IQCP or negedge rstn)
	if (~rstn)
		EN_reg <= 1'b0;
	else
		EN_reg <= IE_int;

always @(posedge IQCP or negedge rstn)
	if (~rstn)
		OQ_reg <= 1'b0;
	else
		if (OQE_int)
			OQ_reg <= OQI_int;
			
			
always @(posedge IQCP or negedge rstn)		
	if (~rstn)
		IQZ <= 1'b0;
	else
		if (IQE_int)
			IQZ <= AND_OUT;
		
// orig value
//wire gpio_c18 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b1 && IQCS == 1'b1);
//wire gpio_c16 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b0 && IQCS == 1'b1);
//wire gpio_c14 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b1 && IQCS == 1'b1);
//wire gpio_c12 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b0 && IQCS == 1'b1);
//wire gpio_c10 = (OSEL == 1'b0  && OQE == 1'b1 && IQCS == 1'b1);
//wire gpio_c8 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b1 && IQCS == 1'b0);
//wire gpio_c6 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b0 && IQCS == 1'b0);
//wire gpio_c4 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b1 && IQCS == 1'b0);
//wire gpio_c2 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b0 && IQCS == 1'b0);
//wire gpio_c0 = (OSEL == 1'b0  && OQE == 1'b1 && IQCS == 1'b0);
//wire gpio_c30 = (IQE == 1'b1  && FIXHOLD == 1'b1 && IN_EN == 1'b1 && IQCS == 1'b1);
//wire gpio_c28 = (IQE == 1'b1  && FIXHOLD == 1'b0 && IN_EN == 1'b1 && IQCS == 1'b1);
//wire gpio_c22 = (IQE == 1'b1  && FIXHOLD == 1'b1 && IN_EN == 1'b1 && IQCS == 1'b0);
//wire gpio_c20 = (IQE == 1'b1  && FIXHOLD == 1'b0 && IN_EN == 1'b1 && IQCS == 1'b0);

// changed one
wire gpio_c18 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 );
wire gpio_c16 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 );
wire gpio_c14 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 );
wire gpio_c12 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 );
wire gpio_c10 = (OSEL == 1'b0  && OQE == 1'b1 );
wire gpio_c8 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c6 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 );
wire gpio_c4 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c2 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c0 = (OSEL == 1'b0  && OQE == 1'b1);
wire gpio_c30 = (IQE == 1'b1  && IN_EN == 1'b0);
wire gpio_c28 = (IQE == 1'b1  && IN_EN == 1'b0);
wire gpio_c22 = (IQE == 1'b1  && IN_EN == 1'b0);
wire gpio_c20 = (IQE == 1'b1  && IN_EN == 1'b0);
specify
if ( IQE == 1'b1  )
(IQC => IQZ) = (0,0,0,0,0,0);
if (IQE == 1'b1 && IN_EN == 1'b0)
(IQC => IQZ) = (0,0,0,0,0,0);
(IQR => IQZ) = (0,0);
if ( IE == 1'b1 && OQE == 1'b1  )
(IQC => IZ) = (0,0,0,0,0,0);
if ( IE == 1'b0 )
(IP => IZ) = (0,0);
if ( IE == 1'b0 && IN_EN == 1'b1  )
(IP => IZ) = (0,0);
$setup (posedge IE,negedge IQC, 0);
$setup (negedge IE,negedge IQC, 0);
$hold (negedge IQC,posedge IE, 0);
$hold (negedge IQC,negedge IE, 0);
$setup (posedge IE,posedge IQC, 0);
$setup (negedge IE,posedge IQC, 0);
$hold (posedge IQC,posedge IE, 0);
$hold (posedge IQC,negedge IE, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c18, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c18, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c18, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c18, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c16, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c16, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c16, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c16, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c14, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c14, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c14, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c14, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c12, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c12, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c12, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c12, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c10, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c10, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c10, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c10, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c8, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c8, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c8, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c8, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c6, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c6, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c6, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c6, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c4, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c4, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c4, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c4, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c2, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c2, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c2, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c2, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c0, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c0, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c0, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c0, 0);
$setup (posedge OQE,negedge IQC, 0);
$setup (negedge OQE,negedge IQC, 0);
$hold (negedge IQC,posedge OQE, 0);
$hold (negedge IQC,negedge OQE, 0);
$setup (posedge OQE,posedge IQC, 0);
$setup (negedge OQE,posedge IQC, 0);
$hold (posedge IQC,posedge OQE, 0);
$hold (posedge IQC,negedge OQE, 0);
$setup (posedge IQE,negedge IQC, 0);
$setup (negedge IQE,negedge IQC, 0);
$hold (negedge IQC,posedge IQE, 0);
$hold (negedge IQC,negedge IQE, 0);
$setup (posedge IQE,posedge IQC, 0);
$setup (negedge IQE,posedge IQC, 0);
$hold (posedge IQC,posedge IQE, 0);
$hold (posedge IQC,negedge IQE, 0);
$recovery (posedge IQR,negedge IQC, 0);
$recovery (negedge IQR,negedge IQC, 0);
$removal (posedge IQR,negedge IQC, 0);
$removal (negedge IQR,negedge IQC, 0);
$recovery (posedge IQR,posedge IQC, 0);
$recovery (negedge IQR,posedge IQC, 0);
$removal (posedge IQR,posedge IQC, 0);
$removal (negedge IQR,posedge IQC, 0);
$setup( posedge IP, negedge IQC &&& gpio_c30, 0);
$setup( negedge IP, negedge IQC &&& gpio_c30, 0);
$hold( negedge IQC, posedge IP &&& gpio_c30, 0);
$hold( negedge IQC, negedge IP &&& gpio_c30, 0);
$setup( posedge IP, negedge IQC &&& gpio_c28, 0);
$setup( negedge IP, negedge IQC &&& gpio_c28, 0);
$hold( negedge IQC, posedge IP &&& gpio_c28, 0);
$hold( negedge IQC, negedge IP &&& gpio_c28, 0);
$setup( posedge IP, posedge IQC &&& gpio_c22, 0);
$setup( negedge IP, posedge IQC &&& gpio_c22, 0);
$hold( posedge IQC, posedge IP &&& gpio_c22, 0);
$hold( posedge IQC, negedge IP &&& gpio_c22, 0);
$setup( posedge IP, posedge IQC &&& gpio_c20, 0);
$setup( negedge IP, posedge IQC &&& gpio_c20, 0);
$hold( posedge IQC, posedge IP &&& gpio_c20, 0);
$hold( posedge IQC, negedge IP &&& gpio_c20, 0);
(IE => IP) = (0,0,0,0,0,0);
if ( IE == 1'b1 )
(OQI => IP) = (0,0);
(IQC => IP) = (0,0,0,0,0,0);
if ( IE == 1'b1 && OQE == 1'b1  )
(IQC => IP) = (0,0,0,0,0,0);
if ( IE == 1'b0 )
(IQR => IP) = (0,0);
endspecify
endmodule

//pragma synthesis_off
module sw_mux (
	port_out,
	default_port,
	alt_port,
	switch
	);
	
	output port_out;
	input default_port;
	input alt_port;
	input switch;
	
	assign port_out = switch ? alt_port : default_port;
	
endmodule
//pragma synthesis_on

`timescale 1ns/10ps
module QMUX (GMUXIN, QHSCK, IS, IZ);
input GMUXIN, QHSCK, IS;
output IZ;

wire GMUXIN_int,  QHSCK_int, IS_int;
buf GMUXIN_buf (GMUXIN_int, GMUXIN) ;
buf QHSCK_buf (QHSCK_int, QHSCK) ;
buf IS_buf (IS_int, IS) ;

assign IZ = IS ? QHSCK_int : GMUXIN_int; 

specify
	if (IS == 1'b0)
   		(GMUXIN => IZ) = (0,0);
	if (IS == 1'b1)
   		(QHSCK => IZ) = (0,0);
   (IS => IZ) = (0,0);
endspecify

endmodule 

module QPMUX (QCLKIN, QHSCK, GMUXIN, IS0, IS1, IZ);
input QCLKIN, QHSCK, GMUXIN, IS0, IS1;
output IZ;

wire GMUXIN_int, QCLKIN_int, QHSCK_int, IS_int;
buf GMUXIN_buf (GMUXIN_int, GMUXIN) ;
buf QHSCK_buf (QHSCK_int, QHSCK) ;
buf QCLKIN_buf (QCLKIN_int, QCLKIN) ;
buf IS0_buf (IS0_int, IS0);
buf IS1_buf (IS1_int, IS1);

//assign IZ = IS0 ? (IS1 ? QHSCK_int : QCLKIN_int) : (IS1 ? QHSCK_int : GMUXIN_int); 
assign IZ = IS0_int ? (IS1_int ? QHSCK_int : GMUXIN_int) : (IS1_int ? QHSCK_int : QCLKIN_int); 

specify
	if (IS0 == 1'b0 && IS1 == 1'b0)
	   (QCLKIN => IZ) = (0,0);
	if (IS0 == 1'b0 && IS1 == 1'b1)
	   (QHSCK => IZ) = (0,0);
	if (IS0 == 1'b1 && IS1 == 1'b0)
	   (GMUXIN => IZ) = (0,0);
   //(IS0 => IZ) = (0,0);
   //(IS1 => IZ) = (0,0);
endspecify

endmodule 

module GMUX(GCLKIN, GHSCK, SSEL, BL_DEN, BL_DYNEN, BL_SEN, BL_VLP, BR_DEN, 
            BR_DYNEN, BR_SEN, 
            BR_VLP, TL_DEN, TL_DYNEN, TL_SEN, TL_VLP, TR_DEN, TR_DYNEN, TR_SEN, TR_VLP, IZ);
input GCLKIN, GHSCK, SSEL, BL_DYNEN, BL_VLP, BR_DEN, BR_DYNEN, BR_SEN, BL_DEN, BL_SEN, 
		 BR_VLP, TL_DEN, TL_DYNEN, TL_SEN, TL_VLP, TR_DEN, TR_DYNEN, TR_SEN, TR_VLP; 
output IZ; 
wire GCLKIN_int, GHSCK_int, SSEL_int;
wire wire_mux_op_0;


buf GCLKIN_buf (GCLKIN_int, GCLKIN) ;
buf GHSCK_buf (GHSCK_int, GHSCK) ;
buf SSEL_buf (SSEL_int, SSEL) ;
//buf SEN_buf (SEN_int, SEN) ;
//buf DYNEN_buf (DYNEN_int, DYNEN) ;
//buf DEN_buf (DEN_int, DEN) ;
//buf VLP_buf (VLP_int, VLP) ;

assign wire_mux_op_0 = SSEL_int ? GHSCK_int : GCLKIN_int;
//assign wire_mux_op_1 = SEN_int ? 1'b1 : 1'b0;
//assign wire_mux_op_2 = DEN_int ? DYNEN_int : wire_mux_op_1;
//assign wire_mux_op_3 = VLP_int ? 1'b0 : wire_mux_op_2;

assign IZ  = wire_mux_op_0;

specify
	if (SSEL == 1'b0 && TL_SEN == 1'b1 && TR_SEN == 1'b1 && BL_SEN == 1'b1 && BR_SEN == 1'b1 && TL_DEN == 1'b0 && TR_DEN == 1'b0 && BL_DEN == 1'b0 && BR_DEN == 1'b0 && TL_VLP == 1'b0 && TR_VLP == 1'b0 && BL_VLP == 1'b0 && BR_VLP == 1'b0)
	   (GCLKIN => IZ) = (0,0);
	if (SSEL == 1'b1 && TL_SEN == 1'b1 && TR_SEN == 1'b1 && BL_SEN == 1'b1 && BR_SEN == 1'b1 && TL_DEN == 1'b0 && TR_DEN == 1'b0 && BL_DEN == 1'b0 && BR_DEN == 1'b0 && TL_VLP == 1'b0 && TR_VLP == 1'b0 && BL_VLP == 1'b0 && BR_VLP == 1'b0)
	   (GHSCK => IZ) = (0,0);

   //(BL_DEN => IZ) = (0,0);
   //(BL_DYNEN => IZ) = (0,0);
	//(BL_SEN => IZ) = (0,0);   
	//(BL_VLP => IZ) = (0,0); 
	//(BR_DEN => IZ) = (0,0);
	//(BR_SEN => IZ) = (0,0); 
    //(BR_VLP => IZ) = (0,0); 
	//(TL_DEN => IZ) = (0,0); 
	//(TL_SEN => IZ) = (0,0); 
	//(TL_VLP => IZ) = (0,0); 
	//(TR_DEN => IZ) = (0,0); 
	//(TR_SEN => IZ) = (0,0); 
	//(TR_VLP => IZ) = (0,0);
    //(BR_DYNEN => IZ) = (0,0); 
	//(TR_DYNEN => IZ) = (0,0); 
	//(TL_DYNEN => IZ) = (0,0); 
endspecify

endmodule 

module SQMUX(QMUXIN, SQHSCK, SELECT, IZ);
input QMUXIN, SQHSCK,SELECT;
output IZ;

wire QMUXIN_int, SQHSCK_int, SELECT_int;

buf QMUXIN_buf (QMUXIN_int, QMUXIN) ;
buf SQHSCK_buf (SQHSCK_int, SQHSCK) ;
buf SELECT_buf (SELECT_int, SELECT) ;

assign IZ = SELECT_int ?  SQHSCK_int : QMUXIN_int;
specify
	if (SELECT == 1'b0)
   		(QMUXIN => IZ) = (0,0);
	if (SELECT == 1'b1)
   		(SQHSCK => IZ) = (0,0);
   //(SELECT => IZ) = (0,0);
endspecify

endmodule


`timescale 1ns/10ps
module SQEMUX(QMUXIN, SQHSCK, DYNEN, SEN, DEN, SELECT, IZ);
input QMUXIN, SQHSCK, DYNEN, SEN, DEN, SELECT;
output IZ;

wire QMUXIN_int, SQHSCK_int, DYNEN_int, SEN_int, DEN_int, SELECT_int;
buf QMUXIN_buf (QMUXIN_int, QMUXIN) ;
buf SQHSCK_buf (SQHSCK_int, SQHSCK) ;
buf DYNEN_buf (DYNEN_int, DYNEN) ;
buf SEN_buf (SEN_int, SEN) ;
buf DEN_buf (DEN_int, DEN) ;
buf SELECT_buf (SELECT_int, SELECT) ;


assign IZ = SELECT_int ?  SQHSCK_int : QMUXIN_int;
	
specify
	if (SELECT == 1'b0 && SEN == 1'b1 && DEN == 1'b0)
	   (QMUXIN => IZ) = (0,0);
	if (SELECT == 1'b1 && SEN == 1'b1 && DEN == 1'b0)
	   (SQHSCK => IZ) = (0,0);
   //(DYNEN => IZ) = (0,0);
   //(SEN => IZ) = (0,0);
   //(DEN => IZ) = (0,0);
   //(SELECT => IZ) = (0,0);
endspecify
endmodule



`timescale 1ns/10ps
module CAND(SEN, CLKIN, IZ);
input SEN, CLKIN;
output IZ;
wire SEN_int, CLKIN_int;
buf SEN_buf (SEN_int, SEN) ;
buf CLKIN_buf (CLKIN_int, CLKIN) ;
assign IZ = CLKIN_int & SEN_int; 

specify
	if (SEN == 1'b1)
	   (CLKIN => IZ) = (0,0);
   //(SEN => IZ) = (0,0);
endspecify
endmodule 

module CANDEN(CLKIN, DYNEN, SEN, DEN, IZ);
input CLKIN, DYNEN, SEN, DEN;
output IZ;
wire CLKIN_int, DYNEN_int, SEN_int, DEN_int; 
wire mux_op0, mux_op1;

buf SEN_buf (SEN_int, SEN) ;
buf CLKIN_buf (CLKIN_int, CLKIN) ;
buf DYNEN_buf (DYNEN_int, DYNEN) ;
buf DEN_buf (DEN_int, DEN) ;

assign mux_op0 = SEN_int ? 1'b1 : 1'b0;
assign mux_op1 = DEN_int ? DYNEN_int : mux_op0;

assign IZ = CLKIN_int & SEN_int; 

specify
	if (SEN == 1'b1 && DEN == 1'b0)
	   (CLKIN => IZ) = (0,0);
   //(DYNEN => IZ) = (0,0);
   //(SEN => IZ) = (0,0);
   //(DEN => IZ) = (0,0);
endspecify

endmodule

`timescale 1ns/10ps
module CLOCK(IP, CEN, IC, OP);
input IP, CEN;
output IC, OP;
buf IP_buf (IP_int, IP) ;
buf CEN_buf (CEN_int, CEN) ;

buf (IC, IP_int);

specify
   (IP => IC) = (0,0);
endspecify


endmodule

// P_MUX3 cell -----------------------------------------------------------------
//

module P_MUX3( A, B, C, D, S, T, E, Z );
input A, B, C, D, S, E, T;
output Z;

udpmux3 QL2 ( Z, A, B, C, D, E, S, T );

specify
   (A => Z) = 0;
   (B => Z) = 0;
   (C => Z) = 0;
   (D => Z) = 0;
   (E => Z) = 0;
   (S => Z) = 0;
   (T => Z) = 0;
endspecify

endmodule

primitive udpmux3(Z, A, B, C, D, E, S, T);
   output Z;
   input A, B, C, D, E, S, T;
   table
   // A  B  C  D  E     S  T   :    Z
      1  ?  ?  ?  ?     0  0   :    1  ;
      0  ?  ?  ?  ?     0  0   :    0  ;
      ?  0  ?  ?  ?     0  1   :    0  ;
      ?  1  ?  ?  ?     0  1   :    1  ;
      ?  ?  0  ?  ?     1  0   :    0  ;
      ?  ?  1  ?  ?     1  0   :    1  ;
      ?  ?  ?  0  ?     1  1   :    0  ;
      ?  ?  ?  1  ?     1  1   :    1  ;
   endtable
endprimitive // udpmux3

// P_MUX2 cell -----------------------------------------------------------------


module P_MUX2( A, B, C, D, S, Z);
input A, B, C, D, S;
output Z;

udpmux2 QL1 ( Z, A, B, C, D, S );

specify
   (A => Z) = 0;
   (B => Z) = 0;
   (C => Z) = 0;
   (D => Z) = 0;
   (S => Z) = 0;
endspecify

endmodule // P_MUX2

// P_BUF cell -----------------------------------------------------------------

module P_BUF( A, Z);
input A;
output Z;

buf QL1 (Z, A);

specify
   (A => Z) = 0;
endspecify

endmodule

primitive udpmux2(Z, A, B, C, D, S);
   output Z;
   input A, B, C, D, S;
   table
      // A  B  C  D  S   :    Z
         1  0  ?  ?  0   :    1  ;
         0  ?  ?  ?  0   :    0  ;
         ?  1  ?  ?  0   :    0  ;
         ?  ?  1  0  1   :    1  ;
         ?  ?  0  ?  1   :    0  ;
         ?  ?  ?  1  1   :    0  ;
// Reduce pessimism
         1  0  1  0  ?   :    1  ;
         0  ?  0  ?  ?   :    0  ;
         0  ?  ?  1  ?   :    0  ; // new
         ?  1  ?  1  ?   :    0  ;
         ?  1  0  ?  ?   :    0  ; // new
   endtable
endprimitive // udpmux2

primitive udpand6(Z, A, B, C, D, E, F);
   output Z;
   input A, B, C, D, E, F;
   table
      // A  B  C  D  E  F  :  Z
         1  0  1  0  1  0  :  1  ;
         0  ?  ?  ?  ?  ?  :  0  ;
         ?  1  ?  ?  ?  ?  :  0  ;
         ?  ?  0  ?  ?  ?  :  0  ;
         ?  ?  ?  1  ?  ?  :  0  ;
         ?  ?  ?  ?  0  ?  :  0  ;
         ?  ?  ?  ?  ?  1  :  0  ;
   endtable
endprimitive // udpand6

module P_AND6( A, B, C, D, E, F, Z );
input A, B, C, D, E, F;
output Z;

udpand6 QL1 ( Z, A, B, C, D, E, F );

specify
   (A => Z) = 0;
   (B => Z) = 0;
   (C => Z) = 0;
   (D => Z) = 0;
   (E => Z) = 0;
   (F => Z) = 0;
endspecify

endmodule // P_AND6

`timescale 1ns/10ps
module SDIOMUX (SD_IP, SD_IZ, SD_OQI, SD_OE);

input  SD_OE, SD_OQI;
output SD_IZ;
inout SD_IP;

assign SD_IP = SD_OE ? SD_OQI : 1'bz;
assign SD_IZ = ~SD_OE ? SD_IP : 1'bz;

specify

if ( SD_OE == 1'b0 ) (SD_IP => SD_IZ) = (0,0);
if ( SD_OE == 1'b1 ) (SD_OQI => SD_IP) = (0,0);

(SD_IP => SD_IZ) = (0,0,0,0,0,0);
(SD_OE => SD_IP) = (0,0,0,0,0,0);

endspecify

endmodule

`timescale 1ns/10ps
module OBUF( IN_OBUF, OUT_OBUF);
input IN_OBUF;
output OUT_OBUF;

buf QL1 (OUT_OBUF, IN_OBUF);

specify
   (IN_OBUF => OUT_OBUF) = 0;
endspecify

endmodule

`timescale 1ns/10ps
module DBUF( IN_DBUF, OUT_DBUF);
input IN_DBUF;
output OUT_DBUF;

buf QL1 (OUT_DBUF, IN_DBUF);

specify
   (IN_DBUF => OUT_DBUF) = 0;
endspecify

endmodule


`timescale 1ns/10ps
module IBUF(IN_IBUF, OUT_IBUF);
input IN_IBUF;
output OUT_IBUF;

buf QL1 (OUT_IBUF, IN_IBUF);

specify
   (IN_IBUF => OUT_IBUF) = 0;
endspecify

endmodule

`timescale 1ns/10ps
module IO_REG (	
		ESEL,
		IE,
		OSEL,
		OQI,
		OQE,	
		FIXHOLD,
		IZ,
		IQZ,
		IQE,
		IQC,
		IQR,
		INEN,
                A2F_reg, 
                F2A_reg_0_, 
                F2A_reg_1_
		);
				
input ESEL;
input IE;
input OSEL;
input OQI;
input OQE;
input FIXHOLD;
output IZ;
output IQZ;
input IQE;
input IQC;
input INEN;
input IQR;
input A2F_reg;
output F2A_reg_0_;
output F2A_reg_1_;
//inout IP;

reg EN_reg, OQ_reg, IQZ;
wire rstn, EN, OQ;

wire FIXHOLD_int;	
wire ESEL_int;
wire IE_int;
wire OSEL_int;
wire OQI_int;
wire INEN_int;
wire OQE_int;
wire IQE_int;
wire IQC_int;
wire IQR_int;
wire A2F_reg_int;
wire A2F_reg_int_buff;
wire fix_hold_mux_out;

parameter IOwithOUTDriver = 0;        //  has to be set for IO with out Driver

buf FIXHOLD_buf (FIXHOLD_int,FIXHOLD);	
buf INEN_buf (INEN_int,INEN);
buf IQC_buf (IQC_int,IQC);
buf IQR_buf (IQR_int,IQR);
buf ESEL_buf (ESEL_int,ESEL);
buf IE_buf (IE_int,IE);
buf OSEL_buf (OSEL_int,OSEL);
buf OQI_buf (OQI_int,OQI);
buf OQE_buf (OQE_int,OQE);
buf IQE_buf (IQE_int,IQE);
buf A2F_reg_buf (A2F_reg_int, A2F_reg);
buf A2F_reg_buf1 (A2F_reg_int_buff, A2F_reg_int);

assign rstn = ~IQR_int;
 if (IOwithOUTDriver)
 begin
	//assign AND_OUT = IQIN_int;

	//assign IZ = IP;
	assign IZ = A2F_reg_int;
 end
 else
  begin
	//assign AND_OUT = INEN_int ? IP : 1'b0;
	// Changing INEN_int, as its functionality is changed now
	//assign AND_OUT = ~INEN_int ? IP : 1'b0;
	assign fix_hold_mux_out = FIXHOLD_int ? A2F_reg_int_buff : A2F_reg_int; 
	//assign AND_OUT = ~INEN_int ? A2F_reg_int : 1'b0;

	//assign IZ = AND_OUT;
	assign IZ = A2F_reg_int;
 end
assign EN = ESEL_int ? IE_int : EN_reg ;

assign OQ = OSEL_int ? OQI_int : OQ_reg ;

assign F2A_reg_1_ = EN; 
assign F2A_reg_0_ = OQ; 
//output F2A_reg_0_;
//output F2A_reg_1_;
//assign IP = EN ? OQ : 1'bz;

//assign (highz1,pull0) IP = WPD ? 1'b0 : 1'b1;
initial
	begin		
		//Power on reset
		EN_reg	= 1'b0;
		OQ_reg= 1'b0;
		IQZ=1'b0;
	end
always @(posedge IQC_int or negedge rstn)
	if (~rstn)
		EN_reg <= 1'b0;
	else
		EN_reg <= IE_int;

always @(posedge IQC_int or negedge rstn)
	if (~rstn)
		OQ_reg <= 1'b0;
	else
		if (OQE_int)
			OQ_reg <= OQI_int;
			
			
always @(posedge IQC_int or negedge rstn)		
	if (~rstn)
		IQZ <= 1'b0;
	else
		if (IQE_int)
			IQZ <= fix_hold_mux_out;
		
// orig value
//wire gpio_c18 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b1 && IQCS == 1'b1);
//wire gpio_c16 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b0 && IQCS == 1'b1);
//wire gpio_c14 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b1 && IQCS == 1'b1);
//wire gpio_c12 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b0 && IQCS == 1'b1);
//wire gpio_c10 = (OSEL == 1'b0  && OQE == 1'b1 && IQCS == 1'b1);
//wire gpio_c8 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b1 && IQCS == 1'b0);
//wire gpio_c6 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b1 && DS == 1'b0 && IQCS == 1'b0);
//wire gpio_c4 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b1 && IQCS == 1'b0);
//wire gpio_c2 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1 && FIXHOLD == 1'b0 && DS == 1'b0 && IQCS == 1'b0);
//wire gpio_c0 = (OSEL == 1'b0  && OQE == 1'b1 && IQCS == 1'b0);
//wire gpio_c30 = (IQE == 1'b1  && FIXHOLD == 1'b1 && INEN == 1'b1 && IQCS == 1'b1);
//wire gpio_c28 = (IQE == 1'b1  && FIXHOLD == 1'b0 && INEN == 1'b1 && IQCS == 1'b1);
//wire gpio_c22 = (IQE == 1'b1  && FIXHOLD == 1'b1 && INEN == 1'b1 && IQCS == 1'b0);
//wire gpio_c20 = (IQE == 1'b1  && FIXHOLD == 1'b0 && INEN == 1'b1 && IQCS == 1'b0);

// changed one
wire gpio_c18 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c16 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c14 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c12 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c10 = (OSEL == 1'b0  && OQE == 1'b1);
wire gpio_c8 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c6 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c4 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c2 = (OSEL == 1'b1  && IE == 1'b1 && IQE == 1'b1);
wire gpio_c0 = (OSEL == 1'b0  && OQE == 1'b1);
wire gpio_c30 = (IQE == 1'b1  && INEN == 1'b0);
wire gpio_c28 = (IQE == 1'b1  && INEN == 1'b0);
wire gpio_c22 = (IQE == 1'b1  && INEN == 1'b0);
wire gpio_c20 = (IQE == 1'b1  && INEN == 1'b0);
wire INEN_EQ_1 = (INEN == 1'b1);
wire FIXHOLD_EQ_1 = (FIXHOLD == 1'b1);
wire FIXHOLD_EQ_0 = (FIXHOLD == 1'b0);
wire ESEL_EQ_0 = (ESEL == 1'b0);
specify
if (IQE == 1'b1)
(IQC => IQZ) = (0,0,0,0,0,0);
(IQR => IQZ) = (0,0);
if ( IE == 1'b1 && OQE == 1'b1  )
(IQC => IZ) = (0,0,0,0,0,0);
(A2F_reg => IZ) = (0,0);
if ( IE == 1'b0 )
(A2F_reg => IZ) = (0,0);
$setup (posedge IE,negedge IQC, 0);
$setup (negedge IE,negedge IQC, 0);
$hold (negedge IQC,posedge IE, 0);
$hold (negedge IQC,negedge IE, 0);
$setup (posedge IE,posedge IQC, 0);
$setup (negedge IE,posedge IQC, 0);
$hold (posedge IQC,posedge IE, 0);
$hold (posedge IQC,negedge IE, 0);
$setup (posedge OQI,posedge IQC, 0);
$setup (negedge OQI,posedge IQC, 0);
$hold (posedge IQC,posedge OQI, 0);
$hold (posedge IQC,negedge OQI, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c18, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c18, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c18, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c18, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c16, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c16, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c16, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c16, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c14, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c14, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c14, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c14, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c12, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c12, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c12, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c12, 0);
$setup( posedge OQI, negedge IQC &&& gpio_c10, 0);
$setup( negedge OQI, negedge IQC &&& gpio_c10, 0);
$hold( negedge IQC, posedge OQI &&& gpio_c10, 0);
$hold( negedge IQC, negedge OQI &&& gpio_c10, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c8, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c8, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c8, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c8, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c6, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c6, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c6, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c6, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c4, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c4, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c4, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c4, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c2, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c2, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c2, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c2, 0);
$setup( posedge OQI, posedge IQC &&& gpio_c0, 0);
$setup( negedge OQI, posedge IQC &&& gpio_c0, 0);
$hold( posedge IQC, posedge OQI &&& gpio_c0, 0);
$hold( posedge IQC, negedge OQI &&& gpio_c0, 0);
$setup (posedge OQE,negedge IQC, 0);
$setup (negedge OQE,negedge IQC, 0);
$hold (negedge IQC,posedge OQE, 0);
$hold (negedge IQC,negedge OQE, 0);
$setup (posedge OQE,posedge IQC, 0);
$setup (negedge OQE,posedge IQC, 0);
$hold (posedge IQC,posedge OQE, 0);
$hold (posedge IQC,negedge OQE, 0);
$setup (posedge IQE,negedge IQC, 0);
$setup (negedge IQE,negedge IQC, 0);
$hold (negedge IQC,posedge IQE, 0);
$hold (negedge IQC,negedge IQE, 0);
$setup (posedge IQE,posedge IQC, 0);
$setup (negedge IQE,posedge IQC, 0);
$hold (posedge IQC,posedge IQE, 0);
$hold (posedge IQC,negedge IQE, 0);
$recovery (posedge IQR,posedge IQC &&& ESEL_EQ_0, 0);
$recovery (negedge IQR,posedge IQC &&& ESEL_EQ_0, 0);
$removal (posedge IQR,posedge IQC &&& ESEL_EQ_0, 0);
$removal (negedge IQR,posedge IQC &&& ESEL_EQ_0, 0);
$recovery (posedge IQR,posedge IQC, 0);
$recovery (negedge IQR,posedge IQC, 0);
$removal (posedge IQR,posedge IQC, 0);
$removal (negedge IQR,posedge IQC, 0);
$setup( posedge A2F_reg, posedge IQC &&& FIXHOLD_EQ_1, 0);
$setup( negedge A2F_reg, posedge IQC &&& FIXHOLD_EQ_1, 0);
$hold( posedge IQC, posedge A2F_reg &&& FIXHOLD_EQ_1, 0);
$hold( posedge IQC, negedge A2F_reg &&& FIXHOLD_EQ_1, 0);
$setup( posedge A2F_reg, posedge IQC &&& FIXHOLD_EQ_0, 0);
$setup( negedge A2F_reg, posedge IQC &&& FIXHOLD_EQ_0, 0);
$hold( posedge IQC, posedge A2F_reg &&& FIXHOLD_EQ_0, 0);
$hold( posedge IQC, negedge A2F_reg &&& FIXHOLD_EQ_0, 0);
$setup( posedge A2F_reg, posedge IQC &&& gpio_c22, 0);
$setup( negedge A2F_reg, posedge IQC &&& gpio_c22, 0);
$hold( posedge IQC, posedge A2F_reg &&& gpio_c22, 0);
$hold( posedge IQC, negedge A2F_reg &&& gpio_c22, 0);
$setup( posedge A2F_reg, posedge IQC &&& gpio_c20, 0);
$setup( negedge A2F_reg, posedge IQC &&& gpio_c20, 0);
$hold( posedge IQC, posedge A2F_reg &&& gpio_c20, 0);
$hold( posedge IQC, negedge A2F_reg &&& gpio_c20, 0);
(IE => F2A_reg_1_) = (0,0,0,0,0,0);
if ( IE == 1'b1 )
(IQC => F2A_reg_1_) = (0,0,0,0,0,0);
if (OSEL == 1'b0 && OQE == 1'b1)
(IQC => F2A_reg_1_) = (0,0,0,0,0,0);
if ( IE == 1'b1 && OQE == 1'b1  )
(OQI => F2A_reg_0_) = (0,0);
(IQC => F2A_reg_0_) = (0,0,0,0,0,0);
if (ESEL == 1'b0)
(IQC => F2A_reg_0_) = (0,0,0,0,0,0);
if ( IE == 1'b0 )
(IQR => F2A_reg_1_) = (0,0);
(IQR => F2A_reg_0_) = (0,0);
endspecify
endmodule

`timescale 1ns/10ps
module logic_0(a); 
output a;
assign a = 1'b0;

endmodule

`timescale 1ns/10ps
module logic_1(a); 
output a;
assign a = 1'b1;

endmodule

`timescale 1ns/10ps
module ioreg (A2F_reg, IE, OQI, ESEL, OSEL, OQE, FIXHOLD, IQE, IQC, INEN, IQR, IQZ, IZ, F2A_reg_0, F2A_reg_1);
input A2F_reg, IE, OQI;
input ESEL, OSEL, OQE, FIXHOLD, INEN;
input IQC, IQE, IQR;
output IQZ, IZ, F2A_reg_0, F2A_reg_1;

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(ESEL),
		.IE(IE),
		.OSEL(OSEL),
		.OQI(OQI),
		.OQE(OQE),	
		.FIXHOLD(FIXHOLD),
		.IZ(IZ),
		.IQZ(IQZ),
		.IQE(IQE),
		.IQC(IQC),
		.IQR(IQR),
		.INEN(INEN),
        .A2F_reg(A2F_reg), 
        .F2A_reg_0_(F2A_reg_0), 
        .F2A_reg_1_(F2A_reg_1));
endmodule
				
`timescale 1ns/10ps
module ck_buff(A, Q); 
input A;
output Q; 
CLOCK CLOCK_QLOGIC_PRIM(.IP(A), .IC(Q), .CEN(), .OP());
endmodule

`timescale 1ns/10ps
module GCLKBUFF(A, Z); 
input A;
output Z; 

SQMUX SQMUX_QLOGIC_PRIM(.QMUXIN(A), .SELECT(1'b1), .SQHSCK(1'b0), .IZ(Z));
endmodule

`timescale 1ns/10ps
module in_buff(A, Q); 
input A;
output Q;

IBUF IBUF_QLOGIC_PRIM(.IN_IBUF(A), .OUT_IBUF(Q));
endmodule

`timescale 1ns/10ps
module out_buff(A, Q); 
input A;
output Q;

OBUF OBUF_QLOGIC_PRIM(.IN_OBUF(A), .OUT_OBUF(Q));
endmodule

`timescale 1ns/10ps
module inv ( A , Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC_INV (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(A),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule

`timescale 1ns/10ps
module buff ( A , Q );

input A;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000010000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(A),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule

`timescale 1ns/10ps
module mux2x0 ( A , B, S, Q ); 
input A, B, S;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000011000100010),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(B),.T0I2(A),.T0I3(S),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule


`timescale 1ns/10ps
module mux4x0 ( A , B, C, D, S0, S1, Q ); 
input A, B, C, D, S0, S1;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000011000100010),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000011000100010),.B0I0(1'b0),.B0I1(D),.B0I2(C),.B0I3(S0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(B),.T0I2(A),.T0I3(S0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(S1),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule


`timescale 1ns/10ps
module mux8x0 ( A , B, C, D, E, F, G, H, S0, S1, S2, Q ); 
input A, B, C, D, E, F, G, H, S0, S1, S2;
output Q;

wire mux_op1, mux_op2;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxx000001100010001000000110001000100000011000100010),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx00000110001000100000011000100010),.B0I0(1'b0),.B0I1(D),.B0I2(C),.B0I3(S0),.B1I0(1'b0),.B1I1(H),.B1I2(G),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(B),.T0I2(A),.T0I3(S0),.T1I0(1'b0),.T1I1(F),.T1I2(E),.T1I3(1'b0),.T2I0(1'b0),.T2I1(mux_op2),.T2I2(mux_op1),.T2I3(S2),.TB0S(S1),.TB1S(S1),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(mux_op1),.C1Z(mux_op2),.C2Z(Q),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule

`timescale 1ns/10ps
module buff_I0( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0100000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(A),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module buff_I1( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0010000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(A),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module buff_I2( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000100000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(A),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module buff_I3( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC_BUFF (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000100000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(A),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module inv_I0( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(A),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module inv_I1( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(A),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module inv_I2( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(A),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module inv_I3( A, Q ); 
input A;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000000000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(A),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module LUT1( I0, O ); 
input I0;
output O;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(I0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(O),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module LUT2( I0, I1, O ); 
input I0, I1;
output O;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(I0),.T0I1(I1),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(O),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module LUT3( I0, I1, I2, O ); 
input I0, I1, I2;
output O;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(I0),.T0I1(I1),.T0I2(I2),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(O),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module LUT4( I0, I1, I2, I3, O ); 
input I0, I1, I2, I3;
output O;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(I0),.T0I1(I1),.T0I2(I2),.T0I3(I3),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(O),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module AND4I0( A, B, C, D, Q ); 
input A, B, C, D;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000000000001),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(D),.T0I1(C),.T0I2(B),.T0I3(A),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module LUT5( I0, I1, I2, I3, I4, O ); 
input I0, I1, I2, I3, I4;
output O;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(I0),.B0I1(I1),.B0I2(I2),.B0I3(I3),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(I0),.T0I1(I1),.T0I2(I2),.T0I3(I3),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(I4),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module carry_out( CI, CO ); 
input CI;
output CO;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000100000000000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(CI),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(CO),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

/*
`timescale 1ns/10ps
module full_adder( A, B, CI, B0CI, S, CO, T0CO ); 
input A, B, CI, B0CI;
output S, CO, T0CO;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1110100010010110),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000100000000),.B0I0(I0),.B0I1(1'b0),.B0I2(B0CI),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(A),.T0I1(B),.T0I2(CI),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(CO),.B1Z(),.B2Z(),.C0Z(S),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(T0CO),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 
*/

`timescale 1ns/10ps
module ff( D, QCK, QEN, QRT, QST, CQZ ); 
input D, QCK, QEN, QRT, QST;
output CQZ;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(QEN),.Q0Z(CQZ),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(QCK),.QCKS(1'b0),.QRT(QRT),.QST(QST),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module qlff( D, QCK, QEN, QRT, QST, CQZ ); 
input D, QCK, QEN, QRT, QST;
output CQZ;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(QEN),.Q0Z(CQZ),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(QCK),.QCKS(1'b0),.QRT(QRT),.QST(QST),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dff( D, CLK, Q); 
input D, CLK;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(1'b1),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffc( D, CLK, CLR, Q); 
input D, CLK, CLR;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(1'b1),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(CLR),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffp( D, CLK, PRE, Q); 
input D, CLK, PRE;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(1'b1),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(PRE),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsc( D, CLK, CLR, Q); 
input D, CLK, CLR;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(1'b1),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(CLR),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffpc( D, CLK, PRE, CLR, Q); 
input D, CLK, CLR, PRE;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(1'b1),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(CLR),.QST(PRE),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffe( D, CLK, EN, Q); 
input D, CLK, EN;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffepc( D, CLK, EN, CLR, PRE, Q); 
input D, CLK, EN, CLR, PRE;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(1'b0),.T0I3(1'b0),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b1),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(D),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(CLR),.QST(PRE),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsec( D, CLK, EN, CLR, Q); 
input D, CLK, EN, CLR;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000010100000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(CLR),.T0I3(D),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsep( P, D, CLK, EN, Q); 
input P, D, CLK, EN;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000100010001000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(D),.T0I3(P),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsle( LD, D, DATA, CLK, EN, Q); 
input LD, D, DATA, CLK, EN;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000101001000100),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(DATA),.T0I2(D),.T0I3(LD),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsep_apc( P, D, CLK, EN, ASET, ARST, Q); 
input P, D, CLK, EN, ASET, ARST;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000100010001000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(D),.T0I3(P),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(ARST),.QST(ASET),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsec_apc( D, CLR, CLK, EN, ASET, ARST, Q); 
input D, CLR, CLK, EN, ASET, ARST;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000010100000),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(1'b0),.T0I2(CLR),.T0I3(D),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(ARST),.QST(ASET),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dffsle_apc( LD, D, DATA, CLK, EN, ASET, ARST, Q); 
input  LD, D, DATA, CLK, EN, ASET, ARST;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000101001000100),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(DATA),.T0I2(D),.T0I3(LD),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(EN),.Q0Z(Q),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(CLK),.QCKS(1'b0),.QRT(ARST),.QST(ASET),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dla(G, D, Q); 
input  G, D;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000101001000100),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(D),.T0I2(Q),.T0I3(G),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dlae(EN, G, D, Q); 
input EN, G, D;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0011010101010101),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(Q),.T0I1(D),.T0I2(G),.T0I3(EN),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dlac(CLR, G, D, Q); 
input CLR, G, D;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000000110101),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(Q),.T0I1(D),.T0I2(G),.T0I3(CLR),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dlaec(EN, G, D, CLR, Q); 
input EN, CLR, G, D;
output Q;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0011010101010101),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000000000000),.B0I0(1'b0),.B0I1(1'b0),.B0I2(1'b0),.B0I3(1'b0),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(Q),.T0I1(D),.T0I2(G),.T0I3(EN),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(CLR),.TB1S(1'b0),.TB2S(1'b0),.B0Z(),.B1Z(),.B2Z(),.C0Z(Q),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module dlad(G, D1, D2, Q1, Q2); 
input G, D1, D2;
output Q1, Q2;

   LOGIC QL_INST_LOGIC (.tFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000101000100010),.bFragBitInfo(64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000101000100010),.B0I0(1'b0),.B0I1(D2),.B0I2(Q2),.B0I3(G),.B1I0(1'b0),.B1I1(1'b0),.B1I2(1'b0),.B1I3(1'b0),.B2I0(1'b0),.B2I1(1'b0),.B2I2(1'b0),.B2I3(1'b0),.T0I0(1'b0),.T0I1(D1),.T0I2(Q1),.T0I3(G),.T1I0(1'b0),.T1I1(1'b0),.T1I2(1'b0),.T1I3(1'b0),.T2I0(1'b0),.T2I1(1'b0),.T2I2(1'b0),.T2I3(1'b0),.TB0S(1'b0),.TB1S(1'b0),.TB2S(1'b0),.B0Z(Q2),.B1Z(),.B2Z(),.C0Z(Q1),.C1Z(),.C2Z(),.B0CO(),.B1CO(),.B2CO(),.B3CO(),.B3I0(1'b0),.B3I1(1'b0),.B3I2(1'b0),.B3I3(1'b0),.B3Z(),.C3Z(),.CD0S(1'b0),.CD1S(1'b1),.CD2S(1'b1),.CD3S(1'b1),.Q0DI(1'b0),.Q0EN(1'b0),.Q0Z(),.Q1DI(1'b0),.Q1EN(1'b0),.Q1Z(),.Q2DI(1'b0),.Q2EN(1'b0),.Q2Z(),.Q3DI(1'b0),.Q3EN(1'b0),.Q3Z(),.QCK(1'b0),.QCKS(1'b0),.QRT(1'b0),.QST(1'b0),.T0CO(),.T1CO(),.T2CO(),.T3CO(),.T3I0(1'b0),.T3I1(1'b0),.T3I2(1'b0),.T3I3(1'b0),.TB3S(1'b0));

endmodule 

`timescale 1ns/10ps
module inpad(P, Q); 
input P;
output Q;

IBUF IBUF_QLOGIC_PRIM(.IN_IBUF(P), .OUT_IBUF(Q));
endmodule

module inpadff (P, FFEN, FFCLR, FFCLK, Q, FFQ);
input P, FFEN, FFCLR, FFCLK;
output Q, FFQ; 

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(1'b0),
		.IE(1'b0),
		.OSEL(1'b0),
		.OQI(1'b0),
		.OQE(1'b0),	
		.FIXHOLD(1'b0),
		.IZ(Q),
		.IQZ(FFQ),
		.IQE(FFEN),
		.IQC(FFCLK),
		.IQR(FFCLR),
		.INEN(1'b0),
        .A2F_reg(P), 
        .F2A_reg_0_(), 
        .F2A_reg_1_());
endmodule
				
`timescale 1ns/10ps
module inpad_ff (P, FFEN, FFCLR, FFCLK, Q, FFQ);
input P, FFEN, FFCLR, FFCLK;
output Q, FFQ; 

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(1'b0),
		.IE(1'b0),
		.OSEL(1'b0),
		.OQI(1'b0),
		.OQE(1'b0),	
		.FIXHOLD(1'b0),
		.IZ(Q),
		.IQZ(FFQ),
		.IQE(FFEN),
		.IQC(FFCLK),
		.IQR(FFCLR),
		.INEN(1'b0),
        .A2F_reg(P), 
        .F2A_reg_0_(), 
        .F2A_reg_1_());
endmodule

`timescale 1ns/10ps
module outpadff (A, FFEN, FFCLR, FFCLK, P);
input A, FFEN, FFCLR, FFCLK;
output P; 

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(1'b0),
		.IE(1'b0),
		.OSEL(1'b0),
		.OQI(A),
		.OQE(FFEN),	
		.FIXHOLD(1'b0),
		.IZ(),
		.IQZ(),
		.IQE(1'b0),
		.IQC(FFCLK),
		.IQR(FFCLR),
		.INEN(1'b0),
        .A2F_reg(), 
        .F2A_reg_0_(), 
        .F2A_reg_1_(P));
endmodule
				
`timescale 1ns/10ps
module outpad_enff (A, FFEN, FFCLR, FFCLK, P);
input A, FFEN, FFCLR, FFCLK;
output P; 

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(1'b0),
		.IE(1'b0),
		.OSEL(1'b0),
		.OQI(A),
		.OQE(FFEN),	
		.FIXHOLD(1'b0),
		.IZ(),
		.IQZ(),
		.IQE(1'b0),
		.IQC(FFCLK),
		.IQR(FFCLR),
		.INEN(1'b0),
        .A2F_reg(1'b0), 
        .F2A_reg_0_(), 
        .F2A_reg_1_(P));
endmodule
				
`timescale 1ns/10ps
module outpad_ff (A, FFCLR, FFCLK, P);
input A, FFCLR, FFCLK;
output P; 

IO_REG IO_REG_QLOGIC_PRIM(	
		.ESEL(1'b0),
		.IE(A),
		.OSEL(1'b0),
		.OQI(1'b0),
		.OQE(1'b0),	
		.FIXHOLD(1'b0),
		.IZ(),
		.IQZ(),
		.IQE(1'b0),
		.IQC(FFCLK),
		.IQR(FFCLR),
		.INEN(1'b0),
        .A2F_reg(1'b0), 
        .F2A_reg_0_(P), 
        .F2A_reg_1_());
endmodule
