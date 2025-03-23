module midi_note_sender (
    input clk,
    input reset,
    input trigger,
    input [3:0] channel,
    input [6:0] note,
    input [6:0] velocity,
    output tx,
    output busy
);
    
    localparam  IDLE = 2'd0,
                SEND_STATUS = 2'd1,
                SEND_NOTE = 2'd2,
                SEND_VELOCITY = 2'd3;    

    reg [1:0] state;

    reg uart_send;
    reg uart_send_d; // delayed data
    reg [7:0] uart_data;
    
    uart_tx uart (
        .clk(clk),
        .reset(reset),
        .send(uart_send),
        .data(uart_data),
        .tx(tx),
        .busy(busy)
    );

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            uart_send <= 0;
            uart_send_d <= 0;
            uart_data <= 0;
            state <= IDLE;
        end else begin
            uart_send_d <= 0;  // pulse send high for one cycle only
            uart_send <= uart_send_d;

            case (state) 
                IDLE: begin
                    if(trigger) begin
                        // TODO: eventually queue a Note Off as well to control note duration
                        state <= SEND_STATUS;
                    end
                end
                SEND_STATUS: begin
                    if(!busy) begin
                        uart_data <= { 4'h9, channel[3:0] }; // NOTE ON status byte
                        uart_send_d <= 1;
                        state <= SEND_NOTE;
                    end
                end 
                SEND_NOTE: begin
                    if(!busy) begin
                        uart_data <= { 1'b0, note[6:0] };
                        uart_send_d <= 1;
                        state <= SEND_VELOCITY;
                    end
                end
                SEND_VELOCITY: begin
                    if(!busy) begin
                        uart_data <= { 1'b0, velocity[6:0] };
                        uart_send_d <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
