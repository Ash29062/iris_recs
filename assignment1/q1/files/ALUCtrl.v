module ALUCtrl (
    input [1:0] ALUOp,       // 2-bit control signal from the main control unit
    input [6:0] funct7,      // 7-bit funct7 field from the instruction
    input [2:0] funct3,      // 3-bit funct3 field from the instruction
    output reg [3:0] ALUCtl  // 4-bit ALU control signal
);

always @(*) begin
    case (ALUOp)
        // Load/Store Instructions (ALUOp = 00): Always ADD
        2'b00: ALUCtl = 4'b0010; // ADD operation

        // Branch Instructions (ALUOp = 01): Always SUBTRACT
        2'b01: ALUCtl = 4'b0110; // SUB operation

        // R-Type Instructions (ALUOp = 10): Use funct7 and funct3 to determine operation
        2'b10: begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000)
                        ALUCtl = 4'b0010; // ADD
                    else if (funct7 == 7'b0100000)
                        ALUCtl = 4'b0110; // SUBTRACT
                end
                3'b111: ALUCtl = 4'b0000; // AND
                3'b110: ALUCtl = 4'b0001; // OR
                3'b100: ALUCtl = 4'b0011; // XOR
                3'b010: ALUCtl = 4'b0111; // SLT (Set Less Than)
                default: ALUCtl = 4'bXXXX; // Undefined operation
            endcase
        end

        // I-Type Arithmetic Instructions (ALUOp = 11): Use funct3 to determine operation
        2'b11: begin
            case (funct3)
                3'b000: ALUCtl = 4'b0010; // ADDI (ADD Immediate)
                3'b111: ALUCtl = 4'b0000; // ANDI (AND Immediate)
                3'b110: ALUCtl = 4'b0001; // ORI (OR Immediate)
                default: ALUCtl = 4'bXXXX; // Undefined operation
            endcase
        end

        default: ALUCtl = 4'bXXXX; // Undefined operation for unsupported ALUOp values
    endcase
end

endmodule
