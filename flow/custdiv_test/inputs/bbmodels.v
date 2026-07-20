module clbalu(
    input wire [15:0] I1,
    input wire [15:0] I0,
    input wire [7:0] CTRL,
    input wire R,
    input wire CIN,
    input wire C,
    output wire COUT,
    output wire [15:0] Q);

    parameter MODE_ALU = 0;

    // MODE 0 - 32-bit pass through mode
    // MODE 1 - add/sub

endmodule

module custdiv(
    input wire [15:0] I1,
    input wire [15:0] I0,
    input wire C,
    output wire [15:0] Q);

    parameter MODE_CUSTDIV = 7;

endmodule
