`include "alarm_clock.v"
`timescale 1ns/1ns

module alarm_clock_tb;

    reg clk;
    reg reset;
    reg [1:0] H_in1;
    reg [3:0] H_in0;
    reg [2:0] M_in1;
    reg [3:0] M_in0;
    reg LD_time;
    reg LD_alarm;
    reg STOP_al;
    reg AL_ON;

    wire Alarm;
    wire [1:0] H_out1;
    wire [3:0] H_out0;
    wire [2:0] M_out1;
    wire [3:0] M_out0;
    wire [2:0] S_out1;
    wire [3:0] S_out0;

    alarm_clock uut (
        .clk(clk),
        .reset(reset),
        .H_in1(H_in1),
        .H_in0(H_in0),
        .M_in1(M_in1),
        .M_in0(M_in0),
        .LD_time(LD_time),
        .LD_alarm(LD_alarm),
        .STOP_al(STOP_al),
        .AL_ON(AL_ON),
        .Alarm(Alarm),
        .H_out1(H_out1),
        .H_out0(H_out0),
        .M_out1(M_out1),
        .M_out0(M_out0),
        .S_out1(S_out1),
        .S_out0(S_out0)
    );

    // Slow clock to simulate 1 Hz (1s per tick)
    always begin
        #500 clk = ~clk;  // 1Hz clock with 1s period = 1000ns full cycle
    end

    initial begin
        $dumpfile("alarm_clock_tb.vcd");
        $dumpvars(0, alarm_clock_tb);

        clk = 0;
        reset = 0;
        LD_time = 0;
        LD_alarm = 0;
        STOP_al = 0;
        AL_ON = 1;

        // Pre-load values
        H_in1 = 2'b00; H_in0 = 4'b0101; // 05
        M_in1 = 3'b000; M_in0 = 4'b0010; // :02

        // Apply reset
        #100 reset = 1;
        #100 reset = 0;

        // Load initial time: 05:02:00
        #500 LD_time = 1;
        #500 LD_time = 0;

        // Load alarm time: 05:03
        #500 H_in0 = 4'b0101; M_in0 = 4'b0011; LD_alarm = 1;
        #500 LD_alarm = 0;

        // Watch output for ~120 seconds (simulate enough time to reach alarm)
        #60000 $finish;
    end

    // Optional monitor for debug
    always @(posedge clk) begin
        $display("TIME: %0d%0d:%0d%0d:%0d%0d | Alarm = %b",
                 H_out1, H_out0, M_out1, M_out0, S_out1, S_out0, Alarm);
    end

endmodule
