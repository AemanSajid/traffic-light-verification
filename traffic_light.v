module traffic_light(
    input clk,
    input reset,
    input pedestrian,
    input emergency,
    output reg red,
    output reg yellow,
    output reg green
);

    parameter RED=0, GREEN=1, YELLOW=2;

    reg [1:0] state;
    reg [3:0] timer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= RED;
            timer <= 0;
        end else begin

            // Emergency override
            if (emergency) begin
                state <= GREEN;
                timer <= 0;
            end else begin
                case(state)

                    RED: begin
                        if (timer >= 3) begin
                            state <= GREEN;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    GREEN: begin
                        if (pedestrian || timer >= 3) begin
                            state <= YELLOW;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    YELLOW: begin
                        if (timer >= 2) begin
                            state <= RED;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                endcase
            end
        end
    end

    always @(*) begin
        red = (state == RED);
        yellow = (state == YELLOW);
        green = (state == GREEN);
    end

endmodule
