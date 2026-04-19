`timescale 1ns/1ps

module tb;

    reg clk;
    reg reset;
    reg pedestrian;
    reg emergency;

    wire red, yellow, green;

    // DUT
    traffic_light dut (
        clk, reset, pedestrian, emergency,
        red, yellow, green
    );

    // Reference model
    reg [1:0] ref_state;
    reg [3:0] ref_timer;

    reg ref_red, ref_yellow, ref_green;

    parameter RED=0, GREEN=1, YELLOW=2;

    // Clock
    always #1 clk = ~clk;

    // Reference logic (same as DUT)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ref_state <= RED;
            ref_timer <= 0;
        end else begin

            if (emergency) begin
                ref_state <= GREEN;
                ref_timer <= 0;
            end else begin
                case(ref_state)

                    RED: begin
                        if (ref_timer >= 3) begin
                            ref_state <= GREEN;
                            ref_timer <= 0;
                        end else ref_timer <= ref_timer + 1;
                    end

                    GREEN: begin
                        if (pedestrian || ref_timer >= 3) begin
                            ref_state <= YELLOW;
                            ref_timer <= 0;
                        end else ref_timer <= ref_timer + 1;
                    end

                    YELLOW: begin
                        if (ref_timer >= 2) begin
                            ref_state <= RED;
                            ref_timer <= 0;
                        end else ref_timer <= ref_timer + 1;
                    end

                endcase
            end
        end
    end

    always @(*) begin
        ref_red = (ref_state == RED);
        ref_yellow = (ref_state == YELLOW);
        ref_green = (ref_state == GREEN);
    end

    // Scoreboard
    integer errors = 0;

    always @(posedge clk) begin
        if (red !== ref_red || yellow !== ref_yellow || green !== ref_green) begin
            $display("MISMATCH at time %0t", $time);
            errors = errors + 1;
        end
    end

    // Stimulus
    initial begin
        clk = 0;
        reset = 1;
        pedestrian = 0;
        emergency = 0;

        #5 reset = 0;

        #20;

        // pedestrian event
        pedestrian = 1;
        #2 pedestrian = 0;

        #20;

        // emergency event
        emergency = 1;
        #2 emergency = 0;

        #20;

        // random testing
        repeat (20) begin
            @(posedge clk);
            pedestrian = $random % 2;
            emergency  = $random % 2;
        end

        #20;

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED, errors = %0d", errors);

        $finish;
    end

    // Monitor
    initial begin
        $monitor("T=%0t | R=%b Y=%b G=%b | P=%b E=%b",
                  $time, red, yellow, green, pedestrian, emergency);
    end

endmodule
