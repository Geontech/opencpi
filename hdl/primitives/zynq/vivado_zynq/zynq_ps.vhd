-- This file is our wrapper around the processing_system7_0 IP as found in
-- EDK/hw/XilinxProcessorIPLib/pcores/processing_system7_v4_03_a/hdl/verilog/processing_system7.v
-- using ds871_processing_system7.pdf
-- There is no logic here, just providing a simpler interface for the platform worker
-- that uses it.
-- The instantiation parameters of processing_system7_0 is based on
-- running XPS in the xps-ocpi project, and looking at the generated wrapper file:
-- system_processing_system7_0_wrapper.v
-- This xps project is mostly for the purpose of generating PS register settings.
-- The instantiation parameters for processing_system7_0 are actually pretty simple.
library IEEE; use IEEE.std_logic_1164.all; use ieee.numeric_std.all;
library ocpi; use ocpi.types.all; -- remove this to avoid all ocpi name collisions
library zynq; use zynq.zynq_pkg.all;
library axi; use axi.axi_pkg.all;
entity zynq_ps is
  port(
    ps_in        : in    pl2ps_t;
    ps_out       : out   ps2pl_t;
    m_axi_gp_in  : in    m_axi_gp_in_array_t(0 to C_M_AXI_GP_COUNT-1);
    m_axi_gp_out : out   m_axi_gp_out_array_t(0 to C_M_AXI_GP_COUNT-1);
    s_axi_gp_in  : in    s_axi_gp_in_array_t(0 to C_S_AXI_GP_COUNT-1);
    s_axi_gp_out : out   s_axi_gp_out_array_t(0 to C_S_AXI_GP_COUNT-1);
    s_axi_hp_in  : in    s_axi_hp_in_array_t(0 to C_S_AXI_HP_COUNT-1);
    s_axi_hp_out : out   s_axi_hp_out_array_t(0 to C_S_AXI_HP_COUNT-1)
    );
end entity zynq_ps;

architecture rtl of zynq_ps is
begin
  -- This instantiation follows the one from the xps-ocpi project, in the file
  -- system_processing_system7_0_wrapper.v
--  ps : processing_system7
  ps : processing_system7_v5_5_processing_system7
    generic map(
      C_EN_EMIO_ENET0 => 0,
      C_EN_EMIO_ENET1 => 0,
      C_EN_EMIO_TRACE => 0,
      C_INCLUDE_TRACE_BUFFER => 0,
      C_TRACE_BUFFER_FIFO_SIZE => 128,
      USE_TRACE_DATA_EDGE_DETECTOR => 0,
      C_TRACE_BUFFER_CLOCK_DELAY => 12,
      C_EMIO_GPIO_WIDTH => 60,
      C_INCLUDE_ACP_TRANS_CHECK => 0,
      C_USE_DEFAULT_ACP_USER_VAL => 0,
      C_S_AXI_ACP_ARUSER_VAL => 31,
      C_S_AXI_ACP_AWUSER_VAL => 31,
      C_DQ_WIDTH => 32,
      C_DQS_WIDTH => 4,
      C_DM_WIDTH => 4,
      C_MIO_PRIMITIVE => 54,
      C_PACKAGE_NAME => "clg484",
      C_PS7_SI_REV => "PRODUCTION",
      C_M_AXI_GP0_ID_WIDTH => 12,
      C_M_AXI_GP0_ENABLE_STATIC_REMAP => 0,
      C_M_AXI_GP1_ID_WIDTH => 12,
      C_M_AXI_GP1_ENABLE_STATIC_REMAP => 0,
      C_S_AXI_GP0_ID_WIDTH => 6,
      C_S_AXI_GP1_ID_WIDTH => 6,
      C_S_AXI_ACP_ID_WIDTH => 3,
      C_S_AXI_HP0_ID_WIDTH => 6,
      C_S_AXI_HP0_DATA_WIDTH => 64,
      C_S_AXI_HP1_ID_WIDTH => 6,
      C_S_AXI_HP1_DATA_WIDTH => 64,
      C_S_AXI_HP2_ID_WIDTH => 6,
      C_S_AXI_HP2_DATA_WIDTH => 64,
      C_S_AXI_HP3_ID_WIDTH => 6,
      C_S_AXI_HP3_DATA_WIDTH => 64,
      C_M_AXI_GP0_THREAD_ID_WIDTH => 12,
      C_M_AXI_GP1_THREAD_ID_WIDTH => 12,
      C_NUM_F2P_INTR_INPUTS => 16,
      C_FCLK_CLK0_BUF => "FALSE",
      C_FCLK_CLK1_BUF => "FALSE",
      C_FCLK_CLK2_BUF => "FALSE",
      C_FCLK_CLK3_BUF => "FALSE"
      )
    port map(
      CAN0_PHY_TX => open,
      CAN0_PHY_RX => '0',
      CAN1_PHY_TX => open,
      CAN1_PHY_RX => '0',
      ENET0_GMII_TX_EN => open,
      ENET0_GMII_TX_ER => open,
      ENET0_MDIO_MDC => open,
      ENET0_MDIO_O => open,
      ENET0_MDIO_T => open,
      ENET0_PTP_DELAY_REQ_RX => open,
      ENET0_PTP_DELAY_REQ_TX => open,
      ENET0_PTP_PDELAY_REQ_RX => open,
      ENET0_PTP_PDELAY_REQ_TX => open,
      ENET0_PTP_PDELAY_RESP_RX => open,
      ENET0_PTP_PDELAY_RESP_TX => open,
      ENET0_PTP_SYNC_FRAME_RX => open,
      ENET0_PTP_SYNC_FRAME_TX => open,
      ENET0_SOF_RX => open,
      ENET0_SOF_TX => open,
      ENET0_GMII_TXD => open,
      ENET0_GMII_COL => '0',
      ENET0_GMII_CRS => '0',
      ENET0_EXT_INTIN => '0',
      ENET0_GMII_RX_CLK => '0',
      ENET0_GMII_RX_DV => '0',
      ENET0_GMII_RX_ER => '0',
      ENET0_GMII_TX_CLK => '0',
      ENET0_MDIO_I => '0',
      ENET0_GMII_RXD => (others => '0'),
      ENET1_GMII_TX_EN => open,
      ENET1_GMII_TX_ER => open,
      ENET1_MDIO_MDC => open,
      ENET1_MDIO_O => open,
      ENET1_MDIO_T => open,
      ENET1_PTP_DELAY_REQ_RX => open,
      ENET1_PTP_DELAY_REQ_TX => open,
      ENET1_PTP_PDELAY_REQ_RX => open,
      ENET1_PTP_PDELAY_REQ_TX => open,
      ENET1_PTP_PDELAY_RESP_RX => open,
      ENET1_PTP_PDELAY_RESP_TX => open,
      ENET1_PTP_SYNC_FRAME_RX => open,
      ENET1_PTP_SYNC_FRAME_TX => open,
      ENET1_SOF_RX => open,
      ENET1_SOF_TX => open,
      ENET1_GMII_TXD => open,
      ENET1_GMII_COL => '0',
      ENET1_GMII_CRS => '0',
      ENET1_EXT_INTIN => '0',
      ENET1_GMII_RX_CLK => '0',
      ENET1_GMII_RX_DV => '0',
      ENET1_GMII_RX_ER => '0',
      ENET1_GMII_TX_CLK => '0',
      ENET1_MDIO_I => '0',
      ENET1_GMII_RXD => (others => '0'),
      GPIO_I => (others => '0'),  -- we need to plumb these out for ZYNQ EMIO PMOD/USB peripherals
      GPIO_O => open,
      GPIO_T => open,
      I2C0_SDA_I => '0',
      I2C0_SDA_O => open,
      I2C0_SDA_T => open,
      I2C0_SCL_I => '0',
      I2C0_SCL_O => open,
      I2C0_SCL_T => open,
      I2C1_SDA_I => '0',
      I2C1_SDA_O => open,
      I2C1_SDA_T => open,
      I2C1_SCL_I => '0',
      I2C1_SCL_O => open,
      I2C1_SCL_T => open,
      PJTAG_TCK => '0',
      PJTAG_TMS => '0',
      PJTAG_TDI => '0',
      PJTAG_TDO => open,
      SDIO0_CLK => open,
      SDIO0_CLK_FB => '0',
      SDIO0_CMD_O => open,
      SDIO0_CMD_I => '0',
      SDIO0_CMD_T => open,
      SDIO0_DATA_I => (others => '0'),
      SDIO0_DATA_O => open,
      SDIO0_DATA_T => open,
      SDIO0_LED => open,
      SDIO0_CDN => '0',
      SDIO0_WP => '0',
      SDIO0_BUSPOW => open,
      SDIO0_BUSVOLT => open,
      SDIO1_CLK => open,
      SDIO1_CLK_FB => '0',
      SDIO1_CMD_O => open,
      SDIO1_CMD_I => '0',
      SDIO1_CMD_T => open,
      SDIO1_DATA_I => (others => '0'),
      SDIO1_DATA_O => open,
      SDIO1_DATA_T => open,
      SDIO1_LED => open,
      SDIO1_CDN => '0',
      SDIO1_WP => '0',
      SDIO1_BUSPOW => open,
      SDIO1_BUSVOLT => open,
      SPI0_SCLK_I => '0',
      SPI0_SCLK_O => open,
      SPI0_SCLK_T => open,
      SPI0_MOSI_I => '0',
      SPI0_MOSI_O => open,
      SPI0_MOSI_T => open,
      SPI0_MISO_I => '0',
      SPI0_MISO_O => open,
      SPI0_MISO_T => open,
      SPI0_SS_I => '0',
      SPI0_SS_O => open,
      SPI0_SS1_O => open,
      SPI0_SS2_O => open,
      SPI0_SS_T => open,
      SPI1_SCLK_I => '0',
      SPI1_SCLK_O => open,
      SPI1_SCLK_T => open,
      SPI1_MOSI_I => '0',
      SPI1_MOSI_O => open,
      SPI1_MOSI_T => open,
      SPI1_MISO_I => '0',
      SPI1_MISO_O => open,
      SPI1_MISO_T => open,
      SPI1_SS_I => '0',
      SPI1_SS_O => open,
      SPI1_SS1_O => open,
      SPI1_SS2_O => open,
      SPI1_SS_T => open,
      UART0_DTRN => open,
      UART0_RTSN => open,
      UART0_TX => open,
      UART0_CTSN => '0',
      UART0_DCDN => '0',
      UART0_DSRN => '0',
      UART0_RIN => '0',
      UART0_RX => '0',
      UART1_DTRN => open,
      UART1_RTSN => open,
      UART1_TX => open,
      UART1_CTSN => '0',
      UART1_DCDN => '0',
      UART1_DSRN => '0',
      UART1_RIN => '0',
      UART1_RX => '0',
      TTC0_WAVE0_OUT => open,
      TTC0_WAVE1_OUT => open,
      TTC0_WAVE2_OUT => open,
      TTC0_CLK0_IN => '0',
      TTC0_CLK1_IN => '0',
      TTC0_CLK2_IN => '0',
      TTC1_WAVE0_OUT => open,
      TTC1_WAVE1_OUT => open,
      TTC1_WAVE2_OUT => open,
      TTC1_CLK0_IN => '0',
      TTC1_CLK1_IN => '0',
      TTC1_CLK2_IN => '0',
      WDT_CLK_IN => '0',
      WDT_RST_OUT => open,
      TRACE_CLK => '0',
      TRACE_CLK_OUT => open,
      TRACE_CTL => open,
      TRACE_DATA => open,
      USB0_PORT_INDCTL => open,
      USB1_PORT_INDCTL => open,
      USB0_VBUS_PWRSELECT => open,
      USB1_VBUS_PWRSELECT => open,
      USB0_VBUS_PWRFAULT => '0',
      USB1_VBUS_PWRFAULT => '0',
      SRAM_INTIN => '0',
      M_AXI_GP0_ARESETN => m_axi_gp_out(0).ARESETN,
      M_AXI_GP0_ARVALID => m_axi_gp_out(0).ARVALID,
      M_AXI_GP0_AWVALID => m_axi_gp_out(0).AWVALID,
      M_AXI_GP0_BREADY => m_axi_gp_out(0).BREADY,
      M_AXI_GP0_RREADY => m_axi_gp_out(0).RREADY,
      M_AXI_GP0_WLAST => m_axi_gp_out(0).WLAST,
      M_AXI_GP0_WVALID => m_axi_gp_out(0).WVALID,
      M_AXI_GP0_ARID => m_axi_gp_out(0).ARID,
      M_AXI_GP0_AWID => m_axi_gp_out(0).AWID,
      M_AXI_GP0_WID => m_axi_gp_out(0).WID,
      M_AXI_GP0_ARBURST => m_axi_gp_out(0).ARBURST,
      M_AXI_GP0_ARLOCK => m_axi_gp_out(0).ARLOCK,
      M_AXI_GP0_ARSIZE => m_axi_gp_out(0).ARSIZE,
      M_AXI_GP0_AWBURST => m_axi_gp_out(0).AWBURST,
      M_AXI_GP0_AWLOCK => m_axi_gp_out(0).AWLOCK,
      M_AXI_GP0_AWSIZE => m_axi_gp_out(0).AWSIZE,
      M_AXI_GP0_ARPROT => m_axi_gp_out(0).ARPROT,
      M_AXI_GP0_AWPROT => m_axi_gp_out(0).AWPROT,
      M_AXI_GP0_ARADDR => m_axi_gp_out(0).ARADDR,
      M_AXI_GP0_AWADDR => m_axi_gp_out(0).AWADDR,
      M_AXI_GP0_WDATA => m_axi_gp_out(0).WDATA,
      M_AXI_GP0_ARCACHE => m_axi_gp_out(0).ARCACHE,
      M_AXI_GP0_ARLEN => m_axi_gp_out(0).ARLEN,
      M_AXI_GP0_ARQOS => m_axi_gp_out(0).ARQOS,
      M_AXI_GP0_AWCACHE => m_axi_gp_out(0).AWCACHE,
      M_AXI_GP0_AWLEN => m_axi_gp_out(0).AWLEN,
      M_AXI_GP0_AWQOS => m_axi_gp_out(0).AWQOS,
      M_AXI_GP0_WSTRB => m_axi_gp_out(0).WSTRB,
      M_AXI_GP0_ACLK => m_axi_gp_in(0).ACLK,
      M_AXI_GP0_ARREADY => m_axi_gp_in(0).ARREADY,
      M_AXI_GP0_AWREADY => m_axi_gp_in(0).AWREADY,
      M_AXI_GP0_BVALID => m_axi_gp_in(0).BVALID,
      M_AXI_GP0_RLAST => m_axi_gp_in(0).RLAST,
      M_AXI_GP0_RVALID => m_axi_gp_in(0).RVALID,
      M_AXI_GP0_WREADY => m_axi_gp_in(0).WREADY,
      M_AXI_GP0_BID => m_axi_gp_in(0).BID,
      M_AXI_GP0_RID => m_axi_gp_in(0).RID,
      M_AXI_GP0_BRESP => m_axi_gp_in(0).BRESP,
      M_AXI_GP0_RRESP => m_axi_gp_in(0).RRESP,
      M_AXI_GP0_RDATA => m_axi_gp_in(0).RDATA,
      M_AXI_GP1_ARESETN => m_axi_gp_out(1).ARESETN,
      M_AXI_GP1_ARVALID => m_axi_gp_out(1).ARVALID,
      M_AXI_GP1_AWVALID => m_axi_gp_out(1).AWVALID,
      M_AXI_GP1_BREADY => m_axi_gp_out(1).BREADY,
      M_AXI_GP1_RREADY => m_axi_gp_out(1).RREADY,
      M_AXI_GP1_WLAST => m_axi_gp_out(1).WLAST,
      M_AXI_GP1_WVALID => m_axi_gp_out(1).WVALID,
      M_AXI_GP1_ARID => m_axi_gp_out(1).ARID,
      M_AXI_GP1_AWID => m_axi_gp_out(1).AWID,
      M_AXI_GP1_WID => m_axi_gp_out(1).WID,
      M_AXI_GP1_ARBURST => m_axi_gp_out(1).ARBURST,
      M_AXI_GP1_ARLOCK => m_axi_gp_out(1).ARLOCK,
      M_AXI_GP1_ARSIZE => m_axi_gp_out(1).ARSIZE,
      M_AXI_GP1_AWBURST => m_axi_gp_out(1).AWBURST,
      M_AXI_GP1_AWLOCK => m_axi_gp_out(1).AWLOCK,
      M_AXI_GP1_AWSIZE => m_axi_gp_out(1).AWSIZE,
      M_AXI_GP1_ARPROT => m_axi_gp_out(1).ARPROT,
      M_AXI_GP1_AWPROT => m_axi_gp_out(1).AWPROT,
      M_AXI_GP1_ARADDR => m_axi_gp_out(1).ARADDR,
      M_AXI_GP1_AWADDR => m_axi_gp_out(1).AWADDR,
      M_AXI_GP1_WDATA => m_axi_gp_out(1).WDATA,
      M_AXI_GP1_ARCACHE => m_axi_gp_out(1).ARCACHE,
      M_AXI_GP1_ARLEN => m_axi_gp_out(1).ARLEN,
      M_AXI_GP1_ARQOS => m_axi_gp_out(1).ARQOS,
      M_AXI_GP1_AWCACHE => m_axi_gp_out(1).AWCACHE,
      M_AXI_GP1_AWLEN => m_axi_gp_out(1).AWLEN,
      M_AXI_GP1_AWQOS => m_axi_gp_out(1).AWQOS,
      M_AXI_GP1_WSTRB => m_axi_gp_out(1).WSTRB,
      M_AXI_GP1_ACLK => m_axi_gp_in(1).ACLK,
      M_AXI_GP1_ARREADY => m_axi_gp_in(1).ARREADY,
      M_AXI_GP1_AWREADY => m_axi_gp_in(1).AWREADY,
      M_AXI_GP1_BVALID => m_axi_gp_in(1).BVALID,
      M_AXI_GP1_RLAST => m_axi_gp_in(1).RLAST,
      M_AXI_GP1_RVALID => m_axi_gp_in(1).RVALID,
      M_AXI_GP1_WREADY => m_axi_gp_in(1).WREADY,
      M_AXI_GP1_BID => m_axi_gp_in(1).BID,
      M_AXI_GP1_RID => m_axi_gp_in(1).RID,
      M_AXI_GP1_BRESP => m_axi_gp_in(1).BRESP,
      M_AXI_GP1_RRESP => m_axi_gp_in(1).RRESP,
      M_AXI_GP1_RDATA => m_axi_gp_in(1).RDATA,      
      S_AXI_GP0_ARESETN => s_axi_gp_out(0).ARESETN,
      S_AXI_GP0_ARREADY => s_axi_gp_out(0).ARREADY,
      S_AXI_GP0_AWREADY => s_axi_gp_out(0).AWREADY,
      S_AXI_GP0_BVALID => s_axi_gp_out(0).BVALID,
      S_AXI_GP0_RLAST => s_axi_gp_out(0).RLAST,
      S_AXI_GP0_RVALID => s_axi_gp_out(0).RVALID,
      S_AXI_GP0_WREADY => s_axi_gp_out(0).WREADY,
      S_AXI_GP0_BRESP => s_axi_gp_out(0).BRESP,
      S_AXI_GP0_RRESP => s_axi_gp_out(0).RRESP,
      S_AXI_GP0_RDATA => s_axi_gp_out(0).RDATA,
      S_AXI_GP0_BID => s_axi_gp_out(0).BID,
      S_AXI_GP0_RID => s_axi_gp_out(0).RID,
      S_AXI_GP0_ACLK => s_axi_gp_in(0).ACLK,
      S_AXI_GP0_ARVALID => s_axi_gp_in(0).ARVALID,
      S_AXI_GP0_AWVALID => s_axi_gp_in(0).AWVALID,
      S_AXI_GP0_BREADY => s_axi_gp_in(0).BREADY,
      S_AXI_GP0_RREADY => s_axi_gp_in(0).RREADY,
      S_AXI_GP0_WLAST => s_axi_gp_in(0).WLAST,
      S_AXI_GP0_WVALID => s_axi_gp_in(0).WVALID,
      S_AXI_GP0_ARBURST => s_axi_gp_in(0).ARBURST,
      S_AXI_GP0_ARLOCK => s_axi_gp_in(0).ARLOCK,
      S_AXI_GP0_ARSIZE => s_axi_gp_in(0).ARSIZE,
      S_AXI_GP0_AWBURST => s_axi_gp_in(0).AWBURST,
      S_AXI_GP0_AWLOCK => s_axi_gp_in(0).AWLOCK,
      S_AXI_GP0_AWSIZE => s_axi_gp_in(0).AWSIZE,
      S_AXI_GP0_ARPROT => s_axi_gp_in(0).ARPROT,
      S_AXI_GP0_AWPROT => s_axi_gp_in(0).AWPROT,
      S_AXI_GP0_ARADDR => s_axi_gp_in(0).ARADDR,
      S_AXI_GP0_AWADDR => s_axi_gp_in(0).AWADDR,
      S_AXI_GP0_WDATA => s_axi_gp_in(0).WDATA,
      S_AXI_GP0_ARCACHE => s_axi_gp_in(0).ARCACHE,
      S_AXI_GP0_ARLEN => s_axi_gp_in(0).ARLEN,
      S_AXI_GP0_ARQOS => s_axi_gp_in(0).ARQOS,
      S_AXI_GP0_AWCACHE => s_axi_gp_in(0).AWCACHE,
      S_AXI_GP0_AWLEN => s_axi_gp_in(0).AWLEN,
      S_AXI_GP0_AWQOS => s_axi_gp_in(0).AWQOS,
      S_AXI_GP0_WSTRB => s_axi_gp_in(0).WSTRB,
      S_AXI_GP0_ARID => s_axi_gp_in(0).ARID,
      S_AXI_GP0_AWID => s_axi_gp_in(0).AWID,
      S_AXI_GP0_WID => s_axi_gp_in(0).WID,
      S_AXI_GP1_ARESETN => s_axi_gp_out(1).ARESETN,
      S_AXI_GP1_ARREADY => s_axi_gp_out(1).ARREADY,
      S_AXI_GP1_AWREADY => s_axi_gp_out(1).AWREADY,
      S_AXI_GP1_BVALID => s_axi_gp_out(1).BVALID,
      S_AXI_GP1_RLAST => s_axi_gp_out(1).RLAST,
      S_AXI_GP1_RVALID => s_axi_gp_out(1).RVALID,
      S_AXI_GP1_WREADY => s_axi_gp_out(1).WREADY,
      S_AXI_GP1_BRESP => s_axi_gp_out(1).BRESP,
      S_AXI_GP1_RRESP => s_axi_gp_out(1).RRESP,
      S_AXI_GP1_RDATA => s_axi_gp_out(1).RDATA,
      S_AXI_GP1_BID => s_axi_gp_out(1).BID,
      S_AXI_GP1_RID => s_axi_gp_out(1).RID,
      S_AXI_GP1_ACLK => s_axi_gp_in(1).ACLK,
      S_AXI_GP1_ARVALID => s_axi_gp_in(1).ARVALID,
      S_AXI_GP1_AWVALID => s_axi_gp_in(1).AWVALID,
      S_AXI_GP1_BREADY => s_axi_gp_in(1).BREADY,
      S_AXI_GP1_RREADY => s_axi_gp_in(1).RREADY,
      S_AXI_GP1_WLAST => s_axi_gp_in(1).WLAST,
      S_AXI_GP1_WVALID => s_axi_gp_in(1).WVALID,
      S_AXI_GP1_ARBURST => s_axi_gp_in(1).ARBURST,
      S_AXI_GP1_ARLOCK => s_axi_gp_in(1).ARLOCK,
      S_AXI_GP1_ARSIZE => s_axi_gp_in(1).ARSIZE,
      S_AXI_GP1_AWBURST => s_axi_gp_in(1).AWBURST,
      S_AXI_GP1_AWLOCK => s_axi_gp_in(1).AWLOCK,
      S_AXI_GP1_AWSIZE => s_axi_gp_in(1).AWSIZE,
      S_AXI_GP1_ARPROT => s_axi_gp_in(1).ARPROT,
      S_AXI_GP1_AWPROT => s_axi_gp_in(1).AWPROT,
      S_AXI_GP1_ARADDR => s_axi_gp_in(1).ARADDR,
      S_AXI_GP1_AWADDR => s_axi_gp_in(1).AWADDR,
      S_AXI_GP1_WDATA => s_axi_gp_in(1).WDATA,
      S_AXI_GP1_ARCACHE => s_axi_gp_in(1).ARCACHE,
      S_AXI_GP1_ARLEN => s_axi_gp_in(1).ARLEN,
      S_AXI_GP1_ARQOS => s_axi_gp_in(1).ARQOS,
      S_AXI_GP1_AWCACHE => s_axi_gp_in(1).AWCACHE,
      S_AXI_GP1_AWLEN => s_axi_gp_in(1).AWLEN,
      S_AXI_GP1_AWQOS => s_axi_gp_in(1).AWQOS,
      S_AXI_GP1_WSTRB => s_axi_gp_in(1).WSTRB,
      S_AXI_GP1_ARID => s_axi_gp_in(1).ARID,
      S_AXI_GP1_AWID => s_axi_gp_in(1).AWID,
      S_AXI_GP1_WID => s_axi_gp_in(1).WID,
      S_AXI_ACP_ARESETN => open,
      S_AXI_ACP_AWREADY => open,
      S_AXI_ACP_ARREADY => open,
      S_AXI_ACP_BVALID => open,
      S_AXI_ACP_RLAST => open,
      S_AXI_ACP_RVALID => open,
      S_AXI_ACP_WREADY => open,
      S_AXI_ACP_BRESP => open,
      S_AXI_ACP_RRESP => open,
      S_AXI_ACP_BID => open,
      S_AXI_ACP_RID => open,
      S_AXI_ACP_RDATA => open,
      S_AXI_ACP_ACLK => '0',
      S_AXI_ACP_ARVALID => '0',
      S_AXI_ACP_AWVALID => '0',
      S_AXI_ACP_BREADY => '0',
      S_AXI_ACP_RREADY => '0',
      S_AXI_ACP_WLAST => '0',
      S_AXI_ACP_WVALID => '0',
      S_AXI_ACP_ARID => (others => '0'),
      S_AXI_ACP_ARPROT => (others => '0'),
      S_AXI_ACP_AWID => (others => '0'),
      S_AXI_ACP_AWPROT => (others => '0'),
      S_AXI_ACP_WID => (others => '0'),
      S_AXI_ACP_ARADDR => (others => '0'),
      S_AXI_ACP_AWADDR => (others => '0'),
      S_AXI_ACP_ARCACHE => (others => '0'),
      S_AXI_ACP_ARLEN => (others => '0'),
      S_AXI_ACP_ARQOS => (others => '0'),
      S_AXI_ACP_AWCACHE => (others => '0'),
      S_AXI_ACP_AWLEN => (others => '0'),
      S_AXI_ACP_AWQOS => (others => '0'),
      S_AXI_ACP_ARBURST => (others => '0'),
      S_AXI_ACP_ARLOCK => (others => '0'),
      S_AXI_ACP_ARSIZE => (others => '0'),
      S_AXI_ACP_AWBURST => (others => '0'),
      S_AXI_ACP_AWLOCK => (others => '0'),
      S_AXI_ACP_AWSIZE => (others => '0'),
      S_AXI_ACP_ARUSER => (others => '0'),
      S_AXI_ACP_AWUSER => (others => '0'),
      S_AXI_ACP_WDATA => (others => '0'),
      S_AXI_ACP_WSTRB => (others => '0'),
      S_AXI_HP0_ARESETN => s_axi_hp_out(0).ARESETN,
      S_AXI_HP0_ARREADY => s_axi_hp_out(0).AR.READY,
      S_AXI_HP0_AWREADY => s_axi_hp_out(0).AW.READY,
      S_AXI_HP0_BVALID => s_axi_hp_out(0).B.VALID,
      S_AXI_HP0_RLAST => s_axi_hp_out(0).R.LAST,
      S_AXI_HP0_RVALID => s_axi_hp_out(0).R.VALID,
      S_AXI_HP0_WREADY => s_axi_hp_out(0).W.READY,
      S_AXI_HP0_BRESP => s_axi_hp_out(0).B.RESP,
      S_AXI_HP0_RRESP => s_axi_hp_out(0).R.RESP,
      S_AXI_HP0_BID => s_axi_hp_out(0).B.ID,
      S_AXI_HP0_RID => s_axi_hp_out(0).R.ID,
      S_AXI_HP0_RDATA => s_axi_hp_out(0).R.DATA,
      S_AXI_HP0_RCOUNT => s_axi_hp_out(0).R.COUNT,
      S_AXI_HP0_WCOUNT => s_axi_hp_out(0).W.COUNT,
      S_AXI_HP0_RACOUNT => s_axi_hp_out(0).AR.COUNT,
      S_AXI_HP0_WACOUNT => s_axi_hp_out(0).AW.COUNT,
      S_AXI_HP0_ACLK => s_axi_hp_in(0).ACLK,
      S_AXI_HP0_ARVALID => s_axi_hp_in(0).AR.VALID,
      S_AXI_HP0_AWVALID => s_axi_hp_in(0).AW.VALID,
      S_AXI_HP0_BREADY => s_axi_hp_in(0).B.READY,
      S_AXI_HP0_RDISSUECAP1_EN => s_axi_hp_in(0).AR.ISSUECAP1_EN,
      S_AXI_HP0_RREADY => s_axi_hp_in(0).R.READY,
      S_AXI_HP0_WLAST => s_axi_hp_in(0).W.LAST,
      S_AXI_HP0_WRISSUECAP1_EN => s_axi_hp_in(0).AW.ISSUECAP1_EN,
      S_AXI_HP0_WVALID => s_axi_hp_in(0).W.VALID,
      S_AXI_HP0_ARBURST => s_axi_hp_in(0).AR.BURST,
      S_AXI_HP0_ARLOCK => s_axi_hp_in(0).AR.LOCK,
      S_AXI_HP0_ARSIZE => s_axi_hp_in(0).AR.SIZE,
      S_AXI_HP0_AWBURST => s_axi_hp_in(0).AW.BURST,
      S_AXI_HP0_AWLOCK => s_axi_hp_in(0).AW.LOCK,
      S_AXI_HP0_AWSIZE => s_axi_hp_in(0).AW.SIZE,
      S_AXI_HP0_ARPROT => s_axi_hp_in(0).AR.PROT,
      S_AXI_HP0_AWPROT => s_axi_hp_in(0).AW.PROT,
      S_AXI_HP0_ARADDR => s_axi_hp_in(0).AR.ADDR,
      S_AXI_HP0_AWADDR => s_axi_hp_in(0).AW.ADDR,
      S_AXI_HP0_ARCACHE => s_axi_hp_in(0).AR.CACHE,
      S_AXI_HP0_ARLEN => s_axi_hp_in(0).AR.LEN,
      S_AXI_HP0_ARQOS => s_axi_hp_in(0).AR.QOS,
      S_AXI_HP0_AWCACHE => s_axi_hp_in(0).AW.CACHE,
      S_AXI_HP0_AWLEN => s_axi_hp_in(0).AW.LEN,
      S_AXI_HP0_AWQOS => s_axi_hp_in(0).AW.QOS,
      S_AXI_HP0_ARID => s_axi_hp_in(0).AR.ID,
      S_AXI_HP0_AWID => s_axi_hp_in(0).AW.ID,
      S_AXI_HP0_WID => s_axi_hp_in(0).W.ID,
      S_AXI_HP0_WDATA => s_axi_hp_in(0).W.DATA,
      S_AXI_HP0_WSTRB => s_axi_hp_in(0).W.STRB,
      S_AXI_HP1_ARESETN => s_axi_hp_out(1).ARESETN,
      S_AXI_HP1_ARREADY => s_axi_hp_out(1).AR.READY,
      S_AXI_HP1_AWREADY => s_axi_hp_out(1).AW.READY,
      S_AXI_HP1_BVALID => s_axi_hp_out(1).B.VALID,
      S_AXI_HP1_RLAST => s_axi_hp_out(1).R.LAST,
      S_AXI_HP1_RVALID => s_axi_hp_out(1).R.VALID,
      S_AXI_HP1_WREADY => s_axi_hp_out(1).W.READY,
      S_AXI_HP1_BRESP => s_axi_hp_out(1).B.RESP,
      S_AXI_HP1_RRESP => s_axi_hp_out(1).R.RESP,
      S_AXI_HP1_BID => s_axi_hp_out(1).B.ID,
      S_AXI_HP1_RID => s_axi_hp_out(1).R.ID,
      S_AXI_HP1_RDATA => s_axi_hp_out(1).R.DATA,
      S_AXI_HP1_RCOUNT => s_axi_hp_out(1).R.COUNT,
      S_AXI_HP1_WCOUNT => s_axi_hp_out(1).W.COUNT,
      S_AXI_HP1_RACOUNT => s_axi_hp_out(1).AR.COUNT,
      S_AXI_HP1_WACOUNT => s_axi_hp_out(1).AW.COUNT,
      S_AXI_HP1_ACLK => s_axi_hp_in(1).ACLK,
      S_AXI_HP1_ARVALID => s_axi_hp_in(1).AR.VALID,
      S_AXI_HP1_AWVALID => s_axi_hp_in(1).AW.VALID,
      S_AXI_HP1_BREADY => s_axi_hp_in(1).B.READY,
      S_AXI_HP1_RDISSUECAP1_EN => s_axi_hp_in(1).AR.ISSUECAP1_EN,
      S_AXI_HP1_RREADY => s_axi_hp_in(1).R.READY,
      S_AXI_HP1_WLAST => s_axi_hp_in(1).W.LAST,
      S_AXI_HP1_WRISSUECAP1_EN => s_axi_hp_in(1).AW.ISSUECAP1_EN,
      S_AXI_HP1_WVALID => s_axi_hp_in(1).W.VALID,
      S_AXI_HP1_ARBURST => s_axi_hp_in(1).AR.BURST,
      S_AXI_HP1_ARLOCK => s_axi_hp_in(1).AR.LOCK,
      S_AXI_HP1_ARSIZE => s_axi_hp_in(1).AR.SIZE,
      S_AXI_HP1_AWBURST => s_axi_hp_in(1).AW.BURST,
      S_AXI_HP1_AWLOCK => s_axi_hp_in(1).AW.LOCK,
      S_AXI_HP1_AWSIZE => s_axi_hp_in(1).AW.SIZE,
      S_AXI_HP1_ARPROT => s_axi_hp_in(1).AR.PROT,
      S_AXI_HP1_AWPROT => s_axi_hp_in(1).AW.PROT,
      S_AXI_HP1_ARADDR => s_axi_hp_in(1).AR.ADDR,
      S_AXI_HP1_AWADDR => s_axi_hp_in(1).AW.ADDR,
      S_AXI_HP1_ARCACHE => s_axi_hp_in(1).AR.CACHE,
      S_AXI_HP1_ARLEN => s_axi_hp_in(1).AR.LEN,
      S_AXI_HP1_ARQOS => s_axi_hp_in(1).AR.QOS,
      S_AXI_HP1_AWCACHE => s_axi_hp_in(1).AW.CACHE,
      S_AXI_HP1_AWLEN => s_axi_hp_in(1).AW.LEN,
      S_AXI_HP1_AWQOS => s_axi_hp_in(1).AW.QOS,
      S_AXI_HP1_ARID => s_axi_hp_in(1).AR.ID,
      S_AXI_HP1_AWID => s_axi_hp_in(1).AW.ID,
      S_AXI_HP1_WID => s_axi_hp_in(1).W.ID,
      S_AXI_HP1_WDATA => s_axi_hp_in(1).W.DATA,
      S_AXI_HP1_WSTRB => s_axi_hp_in(1).W.STRB,
      S_AXI_HP2_ARESETN => s_axi_hp_out(2).ARESETN,
      S_AXI_HP2_ARREADY => s_axi_hp_out(2).AR.READY,
      S_AXI_HP2_AWREADY => s_axi_hp_out(2).AW.READY,
      S_AXI_HP2_BVALID => s_axi_hp_out(2).B.VALID,
      S_AXI_HP2_RLAST => s_axi_hp_out(2).R.LAST,
      S_AXI_HP2_RVALID => s_axi_hp_out(2).R.VALID,
      S_AXI_HP2_WREADY => s_axi_hp_out(2).W.READY,
      S_AXI_HP2_BRESP => s_axi_hp_out(2).B.RESP,
      S_AXI_HP2_RRESP => s_axi_hp_out(2).R.RESP,
      S_AXI_HP2_BID => s_axi_hp_out(2).B.ID,
      S_AXI_HP2_RID => s_axi_hp_out(2).R.ID,
      S_AXI_HP2_RDATA => s_axi_hp_out(2).R.DATA,
      S_AXI_HP2_RCOUNT => s_axi_hp_out(2).R.COUNT,
      S_AXI_HP2_WCOUNT => s_axi_hp_out(2).W.COUNT,
      S_AXI_HP2_RACOUNT => s_axi_hp_out(2).AR.COUNT,
      S_AXI_HP2_WACOUNT => s_axi_hp_out(2).AW.COUNT,
      S_AXI_HP2_ACLK => s_axi_hp_in(2).ACLK,
      S_AXI_HP2_ARVALID => s_axi_hp_in(2).AR.VALID,
      S_AXI_HP2_AWVALID => s_axi_hp_in(2).AW.VALID,
      S_AXI_HP2_BREADY => s_axi_hp_in(2).B.READY,
      S_AXI_HP2_RDISSUECAP1_EN => s_axi_hp_in(2).AR.ISSUECAP1_EN,
      S_AXI_HP2_RREADY => s_axi_hp_in(2).R.READY,
      S_AXI_HP2_WLAST => s_axi_hp_in(2).W.LAST,
      S_AXI_HP2_WRISSUECAP1_EN => s_axi_hp_in(2).AW.ISSUECAP1_EN,
      S_AXI_HP2_WVALID => s_axi_hp_in(2).W.VALID,
      S_AXI_HP2_ARBURST => s_axi_hp_in(2).AR.BURST,
      S_AXI_HP2_ARLOCK => s_axi_hp_in(2).AR.LOCK,
      S_AXI_HP2_ARSIZE => s_axi_hp_in(2).AR.SIZE,
      S_AXI_HP2_AWBURST => s_axi_hp_in(2).AW.BURST,
      S_AXI_HP2_AWLOCK => s_axi_hp_in(2).AW.LOCK,
      S_AXI_HP2_AWSIZE => s_axi_hp_in(2).AW.SIZE,
      S_AXI_HP2_ARPROT => s_axi_hp_in(2).AR.PROT,
      S_AXI_HP2_AWPROT => s_axi_hp_in(2).AW.PROT,
      S_AXI_HP2_ARADDR => s_axi_hp_in(2).AR.ADDR,
      S_AXI_HP2_AWADDR => s_axi_hp_in(2).AW.ADDR,
      S_AXI_HP2_ARCACHE => s_axi_hp_in(2).AR.CACHE,
      S_AXI_HP2_ARLEN => s_axi_hp_in(2).AR.LEN,
      S_AXI_HP2_ARQOS => s_axi_hp_in(2).AR.QOS,
      S_AXI_HP2_AWCACHE => s_axi_hp_in(2).AW.CACHE,
      S_AXI_HP2_AWLEN => s_axi_hp_in(2).AW.LEN,
      S_AXI_HP2_AWQOS => s_axi_hp_in(2).AW.QOS,
      S_AXI_HP2_ARID => s_axi_hp_in(2).AR.ID,
      S_AXI_HP2_AWID => s_axi_hp_in(2).AW.ID,
      S_AXI_HP2_WID => s_axi_hp_in(2).W.ID,
      S_AXI_HP2_WDATA => s_axi_hp_in(2).W.DATA,
      S_AXI_HP2_WSTRB => s_axi_hp_in(2).W.STRB,
      S_AXI_HP3_ARESETN => s_axi_hp_out(3).ARESETN,
      S_AXI_HP3_ARREADY => s_axi_hp_out(3).AR.READY,
      S_AXI_HP3_AWREADY => s_axi_hp_out(3).AW.READY,
      S_AXI_HP3_BVALID => s_axi_hp_out(3).B.VALID,
      S_AXI_HP3_RLAST => s_axi_hp_out(3).R.LAST,
      S_AXI_HP3_RVALID => s_axi_hp_out(3).R.VALID,
      S_AXI_HP3_WREADY => s_axi_hp_out(3).W.READY,
      S_AXI_HP3_BRESP => s_axi_hp_out(3).B.RESP,
      S_AXI_HP3_RRESP => s_axi_hp_out(3).R.RESP,
      S_AXI_HP3_BID => s_axi_hp_out(3).B.ID,
      S_AXI_HP3_RID => s_axi_hp_out(3).R.ID,
      S_AXI_HP3_RDATA => s_axi_hp_out(3).R.DATA,
      S_AXI_HP3_RCOUNT => s_axi_hp_out(3).R.COUNT,
      S_AXI_HP3_WCOUNT => s_axi_hp_out(3).W.COUNT,
      S_AXI_HP3_RACOUNT => s_axi_hp_out(3).AR.COUNT,
      S_AXI_HP3_WACOUNT => s_axi_hp_out(3).AW.COUNT,
      S_AXI_HP3_ACLK => s_axi_hp_in(3).ACLK,
      S_AXI_HP3_ARVALID => s_axi_hp_in(3).AR.VALID,
      S_AXI_HP3_AWVALID => s_axi_hp_in(3).AW.VALID,
      S_AXI_HP3_BREADY => s_axi_hp_in(3).B.READY,
      S_AXI_HP3_RDISSUECAP1_EN => s_axi_hp_in(3).AR.ISSUECAP1_EN,
      S_AXI_HP3_RREADY => s_axi_hp_in(3).R.READY,
      S_AXI_HP3_WLAST => s_axi_hp_in(3).W.LAST,
      S_AXI_HP3_WRISSUECAP1_EN => s_axi_hp_in(3).AW.ISSUECAP1_EN,
      S_AXI_HP3_WVALID => s_axi_hp_in(3).W.VALID,
      S_AXI_HP3_ARBURST => s_axi_hp_in(3).AR.BURST,
      S_AXI_HP3_ARLOCK => s_axi_hp_in(3).AR.LOCK,
      S_AXI_HP3_ARSIZE => s_axi_hp_in(3).AR.SIZE,
      S_AXI_HP3_AWBURST => s_axi_hp_in(3).AW.BURST,
      S_AXI_HP3_AWLOCK => s_axi_hp_in(3).AW.LOCK,
      S_AXI_HP3_AWSIZE => s_axi_hp_in(3).AW.SIZE,
      S_AXI_HP3_ARPROT => s_axi_hp_in(3).AR.PROT,
      S_AXI_HP3_AWPROT => s_axi_hp_in(3).AW.PROT,
      S_AXI_HP3_ARADDR => s_axi_hp_in(3).AR.ADDR,
      S_AXI_HP3_AWADDR => s_axi_hp_in(3).AW.ADDR,
      S_AXI_HP3_ARCACHE => s_axi_hp_in(3).AR.CACHE,
      S_AXI_HP3_ARLEN => s_axi_hp_in(3).AR.LEN,
      S_AXI_HP3_ARQOS => s_axi_hp_in(3).AR.QOS,
      S_AXI_HP3_AWCACHE => s_axi_hp_in(3).AW.CACHE,
      S_AXI_HP3_AWLEN => s_axi_hp_in(3).AW.LEN,
      S_AXI_HP3_AWQOS => s_axi_hp_in(3).AW.QOS,
      S_AXI_HP3_ARID => s_axi_hp_in(3).AR.ID,
      S_AXI_HP3_AWID => s_axi_hp_in(3).AW.ID,
      S_AXI_HP3_WID => s_axi_hp_in(3).W.ID,
      S_AXI_HP3_WDATA => s_axi_hp_in(3).W.DATA,
      S_AXI_HP3_WSTRB => s_axi_hp_in(3).W.STRB,
      DMA0_DATYPE => open,
      DMA0_DAVALID => open,
      DMA0_DRREADY => open,
      DMA0_RSTN => open,
      DMA0_ACLK => '0',
      DMA0_DAREADY => '0',
      DMA0_DRLAST => '0',
      DMA0_DRVALID => '0',
      DMA0_DRTYPE => (others => '0'),
      DMA1_DATYPE => open,
      DMA1_DAVALID => open,
      DMA1_DRREADY => open,
      DMA1_RSTN => open,
      DMA1_ACLK => '0',
      DMA1_DAREADY => '0',
      DMA1_DRLAST => '0',
      DMA1_DRVALID => '0',
      DMA1_DRTYPE => (others => '0'),
      DMA2_DATYPE => open,
      DMA2_DAVALID => open,
      DMA2_DRREADY => open,
      DMA2_RSTN => open,
      DMA2_ACLK => '0',
      DMA2_DAREADY => '0',
      DMA2_DRLAST => '0',
      DMA2_DRVALID => '0',
      DMA3_DRVALID => '0',
      DMA3_DATYPE => open,
      DMA3_DAVALID => open,
      DMA3_DRREADY => open,
      DMA3_RSTN => open,
      DMA3_ACLK => '0',
      DMA3_DAREADY => '0',
      DMA3_DRLAST => '0',
      DMA2_DRTYPE => (others => '0'),
      DMA3_DRTYPE => (others => '0'),
      FTMD_TRACEIN_DATA => (others => '0'),
      FTMD_TRACEIN_VALID => '0',
      FTMD_TRACEIN_CLK => '0',
      FTMD_TRACEIN_ATID => (others => '0'),
      FTMT_F2P_TRIG_0 => '0',
      FTMT_F2P_TRIG_1 => '0',
      FTMT_F2P_TRIG_2 => '0',
      FTMT_F2P_TRIG_3 => '0',
      FTMT_F2P_TRIGACK_0 => open,
      FTMT_F2P_TRIGACK_1 => open,
      FTMT_F2P_TRIGACK_2 => open,
      FTMT_F2P_TRIGACK_3 => open,
      FTMT_F2P_DEBUG => ps_in.debug, -- (others => '0'),
      FTMT_P2F_TRIGACK_0 => '0',
      FTMT_P2F_TRIGACK_1 => '0',
      FTMT_P2F_TRIGACK_2 => '0',
      FTMT_P2F_TRIGACK_3 => '0',
      FTMT_P2F_TRIG_0 => open,
      FTMT_P2F_TRIG_1 => open,
      FTMT_P2F_TRIG_2 => open,
      FTMT_P2F_TRIG_3 => open,
      FTMT_P2F_DEBUG => open,
      FCLK_CLK3 => ps_out.FCLK(3),
      FCLK_CLK2 => ps_out.FCLK(2),
      FCLK_CLK1 => ps_out.FCLK(1),
      FCLK_CLK0 => ps_out.FCLK(0),
      FCLK_CLKTRIG3_N => '0',
      FCLK_CLKTRIG2_N => '0',
      FCLK_CLKTRIG1_N => '0',
      FCLK_CLKTRIG0_N => '0',
      FCLK_RESET3_N => open,
      FCLK_RESET2_N => open,
      FCLK_RESET1_N => open,
      FCLK_RESET0_N => ps_out.FCLKRESET_N,
      FPGA_IDLE_N => '0',
      DDR_ARB => (others => '0'),
      IRQ_F2P => (others => '0'),
      Core0_nFIQ => '0',
      Core0_nIRQ => '0',
      Core1_nFIQ => '0',
      Core1_nIRQ => '0',
      EVENT_EVENTO => open,
      EVENT_STANDBYWFE => open,
      EVENT_STANDBYWFI => open,
      EVENT_EVENTI => '0',
      -- these have no use here since they are hardwired and their I/O configuration
      -- is done in software by programming registers
      MIO                => open, -- ps_inout.MIO,
      DDR_Clk            => open, -- ps_inout.DDR_Clk,
      DDR_Clk_n          => open, -- ps_inout.DDR_Clk_n,
      DDR_CKE            => open, -- ps_inout.DDR_CKE,
      DDR_CS_n           => open, -- ps_inout.DDR_CS_n,
      DDR_RAS_n          => open, -- ps_inout.DDR_RAS_n,
      DDR_CAS_n          => open, -- ps_inout.DDR_CAS_n,
      DDR_WEB            => open, -- ps_inout.DDR_WEB,
      DDR_BankAddr       => open, -- ps_inout.DDR_BankAddr,
      DDR_Addr           => open, -- ps_inout.DDR_Addr,
      DDR_ODT            => open, -- ps_inout.DDR_ODT,
      DDR_DRSTB          => open, -- ps_inout.DDR_DRSTB,
      DDR_DQ             => open, -- ps_inout.DDR_DQ,
      DDR_DM             => open, -- ps_inout.DDR_DM,
      DDR_DQS            => open, -- ps_inout.DDR_DQS,
      DDR_DQS_n          => open, -- ps_inout.DDR_DQS_n,
      DDR_VRN            => open, -- ps_inout.DDR_VRN,
      DDR_VRP            => open, -- ps_inout.DDR_VRP,
      PS_SRSTB           => '0', -- ps_in.PS_SRSTB,
      PS_CLK             => '0', -- ps_in.PS_CLK,
      PS_PORB            => '0', -- ps_in.PS_PORB,
      IRQ_P2F_DMAC_ABORT => open,
      IRQ_P2F_DMAC0 => open,
      IRQ_P2F_DMAC1 => open,
      IRQ_P2F_DMAC2 => open,
      IRQ_P2F_DMAC3 => open,
      IRQ_P2F_DMAC4 => open,
      IRQ_P2F_DMAC5 => open,
      IRQ_P2F_DMAC6 => open,
      IRQ_P2F_DMAC7 => open,
      IRQ_P2F_SMC => open,
      IRQ_P2F_QSPI => open,
      IRQ_P2F_CTI => open,
      IRQ_P2F_GPIO => open,
      IRQ_P2F_USB0 => open,
      IRQ_P2F_ENET0 => open,
      IRQ_P2F_ENET_WAKE0 => open,
      IRQ_P2F_SDIO0 => open,
      IRQ_P2F_I2C0 => open,
      IRQ_P2F_SPI0 => open,
      IRQ_P2F_UART0 => open,
      IRQ_P2F_CAN0 => open,
      IRQ_P2F_USB1 => open,
      IRQ_P2F_ENET1 => open,
      IRQ_P2F_ENET_WAKE1 => open,
      IRQ_P2F_SDIO1 => open,
      IRQ_P2F_I2C1 => open,
      IRQ_P2F_SPI1 => open,
      IRQ_P2F_UART1 => open,
      IRQ_P2F_CAN1 => open
      );
end rtl;
