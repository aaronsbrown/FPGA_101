`ifndef TEST_UTILITIES_SV
`define TEST_UTILITIES_SV

task automatic pretty_print_assert(input bit condition, input string msg);
  if (!condition) begin
    $display("\033[0;31mAssertion Failed: %s\033[0m", msg);
  end else begin
    $display("\033[0;32mAssertion Passed: %s\033[0m", msg);
  end
endtask

`endif