module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // Extract opcode field from instruction
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-Type Instructions (e.g., ADDI, SLTI, ORI, LW, JALR)
            7'b0010011, // ADDI, SLTI, ORI
            7'b0000011, // LW
            7'b1100111: // JALR
                imm = {{20{inst[31]}}, inst[31:20]}; // Sign-extend 12-bit immediate

            // S-Type Instructions (e.g., SW)
            7'b0100011: // SW
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // Combine imm[11:5] and imm[4:0], then sign-extend

            // B-Type Instructions (e.g., BEQ, BNE)
            7'b1100011: // BEQ, BNE
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // Combine imm fields and shift left by 1

            // U-Type Instructions (e.g., LUI, AUIPC)
            7'b0110111, // LUI
            7'b0010111: // AUIPC
                imm = {inst[31:12], 12'b0}; // Immediate is upper 20 bits shifted left by 12

            // J-Type Instructions (e.g., JAL)
            7'b1101111: // JAL
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // Combine imm fields and shift left by 1

            default:
                imm = 32'b0; // Default case for unsupported opcodes
        endcase
    end

endmodule

