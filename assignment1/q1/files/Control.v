module Control (
    input [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite
);

always @(*) begin
    // Default values for all control signals
    branch = 0;
    memRead = 0;
    memtoReg = 0;
    ALUOp = 2'b00;
    memWrite = 0;
    ALUSrc = 0;
    regWrite = 0;

    case (opcode)
        // R-Type Instructions (ADD, SUB)
        7'b0110011: begin
            branch = 0;
            memRead = 0;
            memtoReg = 0;
            ALUOp = 2'b10; // R-type operation (determined by funct3/funct7 in ALU)
            memWrite = 0;
            ALUSrc = 0; // Use registers for ALU inputs
            regWrite = 1; // Write result to rd
        end

        // I-Type Instructions (ADDI, SLTI, ORI)
        7'b0010011: begin
            branch = 0;
            memRead = 0;
            memtoReg = 0;
            ALUOp = 2'b11; // I-type operation (determined by funct3 in ALU)
            memWrite = 0;
            ALUSrc = 1; // Use immediate value for ALU input
            regWrite = 1; // Write result to rd
        end

        // Load Word (LW)
        7'b0000011: begin
            branch = 0;
            memRead = 1; // Enable memory read
            memtoReg = 1; // Write memory data to register
            ALUOp = 2'b00; // Address calculation (add rs1 + imm)
            memWrite = 0;
            ALUSrc = 1; // Use immediate value for address calculation
            regWrite = 1; // Write loaded data to rd
        end

        // Store Word (SW)
        7'b0100011: begin
            branch = 0;
            memRead = 0;
            memtoReg = 0; // Not applicable for store instruction
            ALUOp = 2'b00; // Address calculation (add rs1 + imm)
            memWrite = 1; // Enable memory write
            ALUSrc = 1; // Use immediate value for address calculation
            regWrite = 0; // No register write-back
        end

        // Branch Equal (BEQ)
        7'b1100011: begin
            branch = 1; // Enable branching if condition is met
            memRead = 0;
            memtoReg = 0; // Not applicable for branch instruction
            ALUOp = 2'b01; // Branch comparison operation (subtract rs1 - rs2)
            memWrite = 0;
            ALUSrc = 0; // Use registers for comparison
            regWrite = 0; // No register write-back
        end

        // Jump and Link (JAL)
        7'b1101111: begin
            branch = 0;       // Not a conditional branch but a jump
            memRead = 0;      // No memory read required
            memtoReg = 0;     // Not applicable for jump instruction
            ALUOp = 2'b00;    // No specific ALU operation required for JAL
            memWrite = 0;     // No memory write required
            ALUSrc = 1;       // Use immediate value to calculate the jump address
            regWrite = 1;     // Write return address to rd (link register)
        end

        default: begin
            branch = 0;
            memRead = 0;
            memtoReg = 0;
            ALUOp = 2'b00;
            memWrite = 0;
            ALUSrc = 0;
            regWrite = 0;
        end
    endcase
end

endmodule
