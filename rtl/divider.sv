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
    output logic done,
    output logic [WIDTH+FRAC_BITS-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic dbz
);

localparam N = WIDTH + FRAC_BITS;

typedef enum logic [1:0] {
    IDLE_STATE = 2'b00,
    CALC_STATE = 2'b01,
    DONE_STATE = 2'b10
} state_t;

state_t state;

logic [WIDTH:0] acc; // to hold answer + scratch for running partial remainder
logic [$clog2(N+1)-1:0] i; // iteration count

logic [N-1:0] dvd; // input to consume MSB by MSB
logic [N-1:0] quo; // output to build LSB by LSB
logic [WIDTH-1:0] dvsr_l; // latched divisor
logic dbz_l; // latched divide-by-zero flag

logic [WIDTH:0] acc_shifted; // to shift acc left 1 bring next dividend bits
assign acc_shifted = {acc[WIDTH-1:0], dvd[N-1]}; // tracks curr acc/dvd

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE_STATE;
        busy <= '0;
        done <= '0;

        acc <= '0;
        dbz <= '0;
        quotient <= '0;
        remainder <= '0;

    end else begin
        case (state)
            IDLE_STATE: begin
                done <= 1'b0;
                if (start) begin
                    dvd <= dividend << FRAC_BITS;
                    dvsr_l <= divisor;
                    dbz_l <= (divisor == 0);

                    acc <= '0;
                    quo <= '0;
                    i <= '0;

                    busy <= 1'b1;
                    state <= CALC_STATE;
                end
            end

            CALC_STATE: begin
                dvd <= dvd << 1;

                if (acc_shifted >= dvsr_l) begin // divisible
                    acc <= acc_shifted - dvsr_l;
                    quo <= {quo[N-2:0], 1'b1};
                end else begin // not divisible
                    acc <= acc_shifted;
                    quo <= {quo[N-2:0], 1'b0};
                end

                if (i == N-1) begin
                    state <= DONE_STATE;
                end

                i <= i + 1;
            end

            DONE_STATE: begin
                busy <= 1'b0;
                done <= 1'b1;
                dbz <= dbz_l;

                if (dbz_l) begin
                    quotient <= '0;
                    remainder <= '0;
                end else begin
                    quotient <= quo;
                    remainder <= acc[WIDTH-1:0];
                end

                state <= IDLE_STATE;
            end

            default: begin
                state <= IDLE_STATE;
            end
        endcase
    end
end

endmodule