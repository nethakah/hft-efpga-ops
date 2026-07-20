module divider #(
    parameter WIDTH = 32,
    parameter FRAC_BITS = 0
)(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [WIDTH-1:0] dividend,
    input logic [WIDTH-1:0] divisor,

    output logic busy,
    output logic done
    output logic [WIDTH+FRAC_BITS:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic dbz
);

localparam N = WIDTH + FRAC_BITS;

typedef enum logic [1:0] {
    IDLE = 2'b00,
    CALC = 2'b01,
    DONE = 2'b10,
} state_t;

state_t curr_state;

always_ff @(posedge clk) begin
    if (rst) begin
        blah;
    end else begin
        case (curr_state)
            IDLE: begin
                blah;
            end

            CALC: begin
                blah;
            end

            DONE: begin
                blah;
            end
        endcase
    end
end

endmodule