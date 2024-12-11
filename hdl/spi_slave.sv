// A simple SPI slave to shift register interface to use in this testbench.

module spi_slave #(
  parameter CPOL = 1'b0,
  parameter CPHA = 1'b0,
  parameter CHIP_SELECT_ACTIVE_POLARITY = 1'b0,
  parameter INPUT_SHIFT_REGISTER_SIZE = 0,
  parameter OUTPUT_SHIFT_REGISTER_SIZE = 0 
) (
  input  logic rst,
  input  logic mosi,
  output logic miso,
  input  logic cs,
  input  logic sclk,

  // Ports for the testbench to read and write values
  output logic [MOSI_SHIFT_REGISTER_SIZE-1:0] mosi_val,
  input  logic [MISO_SHIFT_REGISTER_SIZE-1:0] miso_val
)

  logic nsclk;
  logic data_in_clk;
  logic data_out_clk;
  logic cs_active;
  logic [MOSI_SHIFT_REGISTER_SIZE-1:0] mosi_shift_reg;
  logic [MISO_SHIFT_REGISTER_SIZE-1:0] miso_shift_reg; 

  assign cs_active = (CHIP_SELECT_ACTIVE_POLARITY) ? cs : ~cs;
  assign data_in_clk = (CPHA) ? ( (CPOL) ?  (sclk) : (nsclk)) : ( (CPOL) ? (nsclk) : (sclk) );
  assign data_out_clk = (CPHA) ? ( (CPOL) ?  (nsclk) : (sclk)) : ( (CPOL) ? (sclk) : (nsclk) );

  always_comb begin: nsclk
    nsclk = ~sclk;
  end

  always_ff @(posedge data_in_clk) begin: data_in
    if (cs_active) begin
      mosi_shift_reg <= { mosi_shift_reg[MOSI_SHIFT_REGISTER_SIZE-2:0], mosi };
    end
  end

  always_comb begin: miso_out
    miso = miso_shift_reg[MISO_SHIFT_REGISTER_SIZE-1];
  end

  always_ff @(posedge data_out_clk or negedge cs_active) begin: data_out
    if (cs_active) begin
      miso_shift_reg <= { miso_shift_reg[MISO_SHIFT_REGISTER_SIZE-2:0], 1'b0 };
    end
    else begin
      miso_shift_reg <= miso_val;
    end
  end

endmodule: spi_slave
