`timescale 1ps/1ps
module tb_rtl_task5();

// Your testbench goes here.
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;

    task5 DUT(.*);

    always #5 CLOCK_50 = ~CLOCK_50;

    always begin
        CLOCK_50 = 0;
        //SW = 10'b1000000000;
        KEY[3] = 0;
	    KEY[0] = 1;
        #10;
        KEY[3] = 1;
        #20;
        KEY[0] = 0;
        #4000;
	    KEY[0] = 1;
        wait(DUT.rdy == 1);
        #50; //see if anything happens after

        $stop;
    end

endmodule: tb_rtl_task5
