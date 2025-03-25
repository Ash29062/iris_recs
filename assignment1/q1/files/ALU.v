module ALU (
    input [3:0] ALUCtl,      // ALU control signal
    input [31:0] A, B,       // ALU operands
    output reg [31:0] ALUOut, // ALU result
    output zero              // Zero flag
);

    // Zero flag is high when ALUOut is 0
    assign zero = (ALUOut == 32'b0) ? 1'b1 : 1'b0;

    always @(*) begin
        case (ALUCtl)
            4'b0010: ALUOut = A + B;         // ADD
            4'b0110: ALUOut = A - B;         // SUBTRACT
            4'b0000: ALUOut = A & B;         // AND
            4'b0001: ALUOut = A | B;         // OR
            4'b0011: ALUOut = A ^ B;         // XOR
            4'b0111: ALUOut = (A < B) ? 32'b1 : 32'b0; // SLT (Set Less Than)
            4'b1000: ALUOut = A << B[4:0];   // SLL (Shift Left Logical)
            4'b1001: ALUOut = A >> B[4:0];   // SRL (Shift Right Logical)
            4'b1010: ALUOut = $signed(A) >>> B[4:0]; // SRA (Shift Right Arithmetic)
            default: ALUOut = 32'b0;         // Default case
        endcase
    end

endmodule
