/*
 * 24-h alarm clock
 * - T = 1 s tick supplied on port `clk`
 * - Asynchronous active-high reset
 */
module alarm_clock
(
    input  wire        clk, reset,

    /* time-load interface (HH:MM) */
    input  wire [1:0]  H_in1,   // tens of hours  (0-2)
    input  wire [3:0]  H_in0,   // units of hours (0-9, 0-3 when tens==2)
    input  wire [2:0]  M_in1,   // tens of minutes (0-5)
    input  wire [3:0]  M_in0,   // units of minutes(0-9)
    input  wire        LD_time, LD_alarm,

    /* alarm-control interface */
    input  wire        AL_ON,   // enable alarm
    input  wire        STOP_al, // stop / snooze

    /* outputs */
    output reg         Alarm,
    output reg [1:0]   H_out1,
    output reg [3:0]   H_out0,
    output reg [2:0]   M_out1,
    output reg [3:0]   M_out0,
    output reg [2:0]   S_out1,
    output reg [3:0]   S_out0
);

    /* shadow registers that hold the programmed alarm time */
    reg [1:0]  H_alarm1;
    reg [3:0]  H_alarm0;
    reg [2:0]  M_alarm1;
    reg [3:0]  M_alarm0;

    /* === sequential behavior =========================================== */
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            /* ---------- asynchronous reset ---------- */
            {H_out1,H_out0,M_out1,M_out0,S_out1,S_out0} <= 0;
            {H_alarm1,H_alarm0,M_alarm1,M_alarm0}      <= 0;
            Alarm <= 1'b0;
        end
        else begin
            /* ---------- programming of time or alarm ---------- */
            if (LD_time) begin                      // set current time
                {H_out1,H_out0,M_out1,M_out0} <= {H_in1,H_in0,M_in1,M_in0};
                {S_out1,S_out0} <= 0;
            end
            if (LD_alarm) begin                     // set alarm time
                {H_alarm1,H_alarm0,M_alarm1,M_alarm0} <=
                     {H_in1,H_in0,M_in1,M_in0};
            end

            /* ---------- 1-second tick counter ---------- */
            /* seconds (units) */
            if (S_out0 == 4'd9) begin
                S_out0 <= 0;
                /* seconds (tens) */
                if (S_out1 == 3'd5) begin
                    S_out1 <= 0;
                    /* minutes (units) */
                    if (M_out0 == 4'd9) begin
                        M_out0 <= 0;
                        /* minutes (tens) */
                        if (M_out1 == 3'd5) begin
                            M_out1 <= 0;
                            /* hours (units) */
                            if ((H_out1 == 2'd2 && H_out0 == 4'd3) ||
                                 H_out0 == 4'd9) begin
                                H_out0 <= 0;
                                /* hours (tens) */
                                H_out1 <= (H_out1 == 2'd2) ? 0 : H_out1 + 1;
                            end
                            else H_out0 <= H_out0 + 1;
                        end
                        else M_out1 <= M_out1 + 1;
                    end
                    else M_out0 <= M_out0 + 1;
                end
                else S_out1 <= S_out1 + 1;
            end
            else begin
                S_out0 <= S_out0 + 1;               // normal 0-9 count
            end

            /* ---------- alarm comparator ---------- */
            if (AL_ON &&
                H_alarm1 == H_out1 && H_alarm0 == H_out0 &&
                M_alarm1 == M_out1 && M_alarm0 == M_out0)
                Alarm <= 1'b1;                      // raise alarm
            else if (STOP_al)
                Alarm <= 1'b0;                      // user silenced it
            /* Otherwise keep previous state
               (avoids “one-minute stickiness”)     */
        end
    end
endmodule
