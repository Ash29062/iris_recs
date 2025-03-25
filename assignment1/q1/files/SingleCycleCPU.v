module SingleCycleCPU (
    input clk,
    input start
);

    // Wires to connect components
    wire [31:0] pc, pc_next,pc_t, pc_plus4, instruction, imm, imm_shifted, alu_result, mem_data, write_data;
    wire [31:0] read_data1, read_data2, alu_src_b;
    wire [3:0] alu_control;
    wire zero, branch_taken;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7; // Adjusted to match the actual size of funct7

    // Control signals
    wire branch, memRead, memtoReg, memWrite, ALUSrc, regWrite;
    wire [1:0] ALUOp;

    // Program Counter
    PC m_PC(
        .clk(clk),           // Clock signal
        .rst(start),        // Reset when start is low
        .pc_i(pc_t),
        .pc_o(pc)
    );

    // Adder for PC + 4
    Adder m_Adder_1(
        .a(pc),
        .b(32'd4),
        .sum(pc_plus4)
    );

    // Instruction Memory
    InstructionMemory m_InstMem(
        .readAddr(pc),
        .inst(instruction)
    );

    // Extract fields from instruction
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[30:25]; // Adjusted to match the actual size of funct7

    // Control Unit
    Control m_Control(
        .opcode(opcode),
        .branch(branch),
        .memRead(memRead),
        .memtoReg(memtoReg),
        .ALUOp(ALUOp),
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .regWrite(regWrite)
    );

    // Register File
    Register m_Register(
        .clk(clk),
        .rst(~start),       // Reset when start is low
        .regWrite(regWrite),
        .readReg1(instruction[19:15]),
        .readReg2(instruction[24:20]),
        .writeReg(instruction[11:7]),
        .writeData(write_data),
        .readData1(read_data1),
        .readData2(read_data2)
    );

    // Immediate Generator
    ImmGen #(.Width(32)) m_ImmGen(
        .inst(instruction),
        .imm(imm)
    );

    // Shift Left 1 for Branch Target Calculation
    ShiftLeftOne m_ShiftLeftOne(
        .i(imm),            // Input immediate value
        .o(imm_shifted)     // Output shifted immediate value (connected to a valid wire)
    );

    // Adder for Branch Target Address
    Adder m_Adder_2(
        .a(pc),
        .b(imm_shifted),       // Branch target address calculation
        .sum(pc_next)          // Branch target address output
    );

    // ALU Control Unit
    ALUCtrl m_ALUCtrl(
        .ALUOp(ALUOp),
        .funct7(funct7),      // Adjusted to match the actual size of funct7
        .funct3(funct3),
        .ALUCtl(alu_control)
    );

    // ALU Source MUX (Select between register and immediate)
    Mux2to1 #(.size(32)) m_Mux_ALU(
        .sel(ALUSrc),
        .s0(read_data2),     // Register value (rs2)
        .s1(imm),            // Immediate value
        .out(alu_src_b)      // Output to ALU input B
    );

    // ALU
    ALU m_ALU(
        .ALUCtl(alu_control),
        .A(read_data1),      // Register value (rs1)
        .B(alu_src_b),       // Second operand (from MUX)
        .ALUOut(alu_result), // Result of ALU operation
        .zero(zero)          // Zero flag for branch condition
    );

    // Data Memory
    DataMemory m_DataMemory(
        .rst(~start),         // Reset when start is low
        .clk(clk),            // Clock signal
        .memWrite(memWrite),  // Write enable signal
        .memRead(memRead),    // Read enable signal
        .address(alu_result), // Address from ALU result
        .writeData(read_data2),// Data to write (from rs2)
        .readData(mem_data)   // Data read from memory
    );

    // Write Data MUX (Select between memory data and ALU result)
    Mux2to1 #(.size(32)) m_Mux_WriteData(
        .sel(memtoReg),
        .s0(alu_result),      // ALU result (e.g., for R-type instructions)
        .s1(mem_data),         // Memory data (e.g., for LW instruction)
        .out(write_data)      // Output to write back to register file
    );

    // PC Source MUX (Select between PC + 4 and branch target address)
    assign branch_taken = branch & zero;  // Branch condition met if branch=1 and zero=1

    Mux2to1 #(.size(32)) m_Mux_PC(
        .sel(branch_taken),   // Select based on branch condition
        .s0(pc_plus4),         // PC + 4 (normal execution)
        .s1(pc_next),          // Branch target address (if branch taken)
        .out(pc_t)          // Output to program counter input
    );

endmodule
