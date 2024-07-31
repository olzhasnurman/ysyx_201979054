/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ---------------------------------------------------------------
// This is a address increment module that increments the address 
// by 4 when seding data in burst using AXI4-Lite protocol.
// ---------------------------------------------------------------

module ysyx_201979054_addr_increment 
#(
    parameter AXI_ADDR_WIDTH = 64,
              INCR_VAL       = 64'd4
) 
(
    // Control Signal.
    input  logic clk,
    input  logic run,
    input  logic arst,
    input  logic enable,

    // Input interface.
    input  logic [ AXI_ADDR_WIDTH - 1:0 ] i_addr,

    // Output interface. 
    output logic [ AXI_ADDR_WIDTH - 1:0 ] o_addr
);

    logic [ AXI_ADDR_WIDTH - 1:0 ] s_count;

    always_ff @( posedge clk, posedge arst ) begin
        if      ( arst   ) s_count <= '0;
        else if ( ~run   ) s_count <= '0;
        else if ( enable ) s_count <= s_count + INCR_VAL;
    end

    assign o_addr = i_addr + s_count;
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// --------------------------------------
// This is a Arithmetic Logic Unit (ALU).
// --------------------------------------

module ysyx_201979054_alu 
// Parameters.
#(
    parameter DATA_WIDTH    = 64,
              WORD_WIDTH    = 32,
              CONTROL_WIDTH = 5   
) 
// Port decleration.
(
    // ALU control signal.
    input  logic [ CONTROL_WIDTH - 1:0 ] alu_control,

    // Input interface.
    input  logic [ DATA_WIDTH    - 1:0 ] i_src_1,
    input  logic [ DATA_WIDTH    - 1:0 ] i_src_2,

    // Output interface.
    output logic [ DATA_WIDTH    - 1:0 ] o_alu_result,
    output logic                         o_zero_flag,
    output logic                         o_slt_flag,
    output logic                         o_sltu_flag
);

    // ---------------
    // Oprations.
    // ---------------
    localparam ADD   = 5'b00000;
    localparam SUB   = 5'b00001;
    localparam AND   = 5'b00010;
    localparam OR    = 5'b00011;
    localparam XOR   = 5'b00100;
    localparam SLL   = 5'b00101;
    localparam SLT   = 5'b00110;
    localparam SLTU  = 5'b00111;
    localparam SRL   = 5'b01000;
    localparam SRA   = 5'b01001;

    localparam ADDW  = 5'b01010;
    localparam SUBW  = 5'b01011;
    localparam SLLW  = 5'b01100;
    localparam SRLW  = 5'b01101;
    localparam SRAW  = 5'b01110;
    localparam ADDIW = 5'b01111;
    
    localparam CSRRW = 5'b10000;
    localparam CSRRS = 5'b10001;
    localparam CSRRC = 5'b10010;




    //-------------------------
    // Internal nets.
    //-------------------------
    
    // ALU regular & immediate operation outputs.
    logic [ DATA_WIDTH - 1:0 ] s_add_out;
    logic [ DATA_WIDTH - 1:0 ] s_sub_out;
    logic [ DATA_WIDTH - 1:0 ] s_and_out;
    logic [ DATA_WIDTH - 1:0 ] s_or_out;
    logic [ DATA_WIDTH - 1:0 ] s_xor_out;
    logic [ DATA_WIDTH - 1:0 ] s_sll_out;
    logic [ DATA_WIDTH - 1:0 ] s_srl_out;
    logic [ DATA_WIDTH - 1:0 ] s_sra_out;

    logic less_than;
    logic less_than_u;

    // ALU word operation outputs.
    logic [ WORD_WIDTH - 1:0 ] s_addw_out;
    logic [ WORD_WIDTH - 1:0 ] s_subw_out;
    logic [ WORD_WIDTH - 1:0 ] s_sllw_out;
    logic [ WORD_WIDTH - 1:0 ] s_srlw_out;
    logic [ WORD_WIDTH - 1:0 ] s_sraw_out;

    // Flag signals. 
    // logic s_carry_flag_add;
    // logic s_carry_flag_sub;
    // logic s_overflow;

    // NOTE: REVIEW SLT & SLTU INSTRUCTIONS. ALSO FLAGS.

    //---------------------------------
    // Arithmetic & Logic Operations.
    //---------------------------------
    
    // ALU regular & immediate operations. 
    assign s_add_out = i_src_1 + i_src_2;
    assign s_sub_out = $unsigned($signed(i_src_1) - $signed(i_src_2));
    assign s_and_out = i_src_1 & i_src_2;
    assign s_or_out  = i_src_1 | i_src_2;
    assign s_xor_out = i_src_1 ^ i_src_2;
    assign s_sll_out = i_src_1 << i_src_2[5:0];
    assign s_srl_out = i_src_1 >> i_src_2[5:0];
    assign s_sra_out = $unsigned($signed(i_src_1) >>> i_src_2[5:0]);

    assign less_than   = $signed(i_src_1) < $signed(i_src_2);
    assign less_than_u = i_src_1 < i_src_2;

    // ALU word operations.
    assign s_addw_out = i_src_1[31:0] + i_src_2[31:0];
    assign s_subw_out = $unsigned($signed(i_src_1[31:0]) -  $signed(i_src_2[31:0])); 
    assign s_sllw_out = i_src_1[31:0] << i_src_2[4:0];
    assign s_srlw_out = i_src_1[31:0] >> i_src_2[4:0];
    assign s_sraw_out = $unsigned($signed(i_src_1[31:0]) >>> i_src_2[4:0]);


    // Flags. 
    assign o_zero_flag = !(|o_alu_result);
    assign o_slt_flag  = less_than;
    assign o_sltu_flag = less_than_u;
    // assign s_overflow      = (o_alu_result[DATA_WIDTH - 1] ^ i_src_1[DATA_WIDTH - 1]) & 
    //                          (i_src_2[DATA_WIDTH - 1] ~^ i_src_1[DATA_WIDTH - 1] ~^ alu_control[0]);


    // ---------------------------
    // Output MUX.
    // ---------------------------
    always_comb begin
        // Default values.
        o_alu_result    = '0;

        case ( alu_control )
            ADD  : o_alu_result = s_add_out;
            SUB  : o_alu_result = s_sub_out;
            AND  : o_alu_result = s_and_out;
            OR   : o_alu_result = s_or_out;
            XOR  : o_alu_result = s_xor_out;
            SLL  : o_alu_result = s_sll_out;
            SLT  : o_alu_result = { { (DATA_WIDTH - 1) { 1'b0 } }, less_than };
            SLTU : o_alu_result = { { (DATA_WIDTH - 1) { 1'b0 } }, less_than_u };
            SRL  : o_alu_result = s_srl_out;
            SRA  : o_alu_result = s_sra_out;

            ADDW : o_alu_result = { { 32{s_addw_out[31]} }, s_addw_out };
            SUBW : o_alu_result = { { 32{s_subw_out[31]} }, s_subw_out };
            SLLW : o_alu_result = { { 32{s_sllw_out[31]} }, s_sllw_out };
            SRLW : o_alu_result = { { 32{s_srlw_out[31]} }, s_srlw_out };
            SRAW : o_alu_result = { { 32{s_sraw_out[31]} }, s_sraw_out };

            ADDIW: o_alu_result = { { 32{s_add_out[31]} }, s_add_out[31:0] };

            CSRRW: o_alu_result = i_src_1;
            CSRRS: o_alu_result = s_or_out;
            CSRRC: o_alu_result = ( ~ i_src_1) & i_src_2;

            default: begin
                o_alu_result    = 'b0;
            end 
        endcase

    end   
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------
// ALU decoder is a module designed to output alu control signal based on
// op[5], alu_op, func_3, func_7[5] signals. 
// -----------------------------------------------------------------------

module ysyx_201979054_alu_decoder 
// Port delerations. 
(
    // Input interface.
    input  logic [2:0] i_alu_op,
    input  logic [2:0] i_func_3,
    input  logic       i_func_7_5,
    input  logic       i_op_5,

    // Output interface. 
    output logic [4:0] o_alu_control,
    output logic       o_illegal_instr
);

    logic [1:0] s_op_func_7;

    assign s_op_func_7 = { i_op_5, i_func_7_5 };

    // ALU decoder logic.
    always_comb begin 
        o_illegal_instr = 1'b0;

        case ( i_alu_op )
            3'b000: o_alu_control = 5'b00000; // ADD for I type instruction: lw, sw.
            3'b001: o_alu_control = 5'b00001; // SUB  for B type instructions: beq, bne.

            // I & R Type.
            3'b010: 
                case (i_func_3)
                    3'b000: if ( s_op_func_7 == 2'b11 ) o_alu_control = 5'b00001; // sub instruciton.
                            else                        o_alu_control = 5'b00000; // add & addi instruciton.

                    3'b001: o_alu_control = 5'b00101; // sll & slli instructions.

                    3'b010: o_alu_control = 5'b00110; // slt instruction. 

                    3'b011: o_alu_control = 5'b00111; // sltu instruction.

                    3'b100: o_alu_control = 5'b00100; // xor instruction.

                    3'b101: 
                        case ( i_func_7_5 )
                            1'b0:   o_alu_control = 5'b01000; // srl & srli instructions.
                            1'b1:   o_alu_control = 5'b01001; // sra & srai instructions. 
                            default: o_alu_control = '0; 
                        endcase

                    3'b110: o_alu_control = 5'b00011; // or instruction.

                    3'b111: o_alu_control = 5'b00010; // and instruction.

                    default: o_alu_control = 5'b00000; // add instrucito for default. 
                endcase

            // I & R Type W.
            3'b011: 
                case ( i_func_3 )
                    3'b000: 
                        case ( s_op_func_7 )
                            2'b11:   o_alu_control = 5'b01011; // SUBW.
                            2'b10:   o_alu_control = 5'b01010; // ADDW.
                            default: o_alu_control = 5'b01111; // ADDIW.
                        endcase
                    3'b001: o_alu_control = 5'b01100; // SLLIW or SLLW
                    3'b101: if ( i_func_7_5 ) o_alu_control = 5'b01110; // SRAIW or SRAW.
                            else              o_alu_control = 5'b01101; // SRLIW or SRLW. 
                    default: begin
                        o_alu_control   = 5'b00000;
                        o_illegal_instr = 1'b1;                        
                    end
                endcase 

            // CSR.
            3'b100: 
                case ( i_func_3[1:0] ) 
                    2'b01: o_alu_control = 5'b10000;
                    2'b10: o_alu_control = 5'b10001;
                    2'b11: o_alu_control = 5'b10010;
                    default: begin
                        o_alu_control   = '0;
                        o_illegal_instr = 1'b1; 
                    end
                endcase
            
            default: begin
                o_alu_control   = '0;
                o_illegal_instr = 1'b1;
            end

        endcase
    end

    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------------------------------------------------------
// This is a AXI4 Master module implementation for communication with outside memory.
// -------------------------------------------------------------------------------------------------------------

module ysyx_201979054_axi4_master
(
    // Control signals.
    input  logic clk,
    input  logic arst,
    input  logic io_interrupt,

    // Interface with CPU.
    input  logic          i_write_req,
    input  logic          i_read_req,
    input  logic [ 31:0 ] i_addr,
    input  logic [ 63:0 ] i_write_data,
    input  logic [  7:0 ] i_axi_len,
    input  logic [  2:0 ] i_axi_size,
    input  logic [  1:0 ] i_axi_burst,
    input  logic [  7:0 ] i_axi_strb,
    output logic [ 63:0 ] o_read_data,
    output logic          o_axi_done,
    output logic          o_axi_handshake,

    // AXI4 Master Bus: Write Interface.
    input  logic 	      i_awready,   // +
    output logic 	      o_awvalid,   // +
    output logic [  3:0 ] o_awid,      // +
    output logic [ 31:0 ] o_awaddr,    // +
    output logic [  7:0 ] o_awlen,     // +
    output logic [  2:0 ] o_awsize,    // +
    output logic [  1:0 ] o_awburst,   // +
    input  logic 	      i_wready,    // +
    output logic 	      o_wvalid,    // +
    output logic [ 63:0 ] o_wdata,     // +
    output logic [  7:0 ] o_wstrb,     // + 
    output logic 	      o_wlast,     // +
    output logic 	      o_bready,    // +
    input  logic 	      i_bvalid,    // +
    input  logic [  3:0 ] i_bid,       // +
    input  logic [  1:0 ] i_bresp,     // +
    
    // AXI4 Master Bus: Write Interface.
    input  logic 	      i_arready, // +
    output logic 	      o_arvalid, // +
    output logic [  3:0 ] o_arid,    // +
    output logic [ 31:0 ] o_araddr,  // +
    output logic [  7:0 ] o_arlen,   // +
    output logic [  2:0 ] o_arsize,  // +
    output logic [  1:0 ] o_arburst, // +
    output logic 	      o_rready,  // +
    input  logic 	      i_rvalid,  // +
    input  logic [  3:0 ] i_rid,     // 
    input  logic [  1:0 ] i_rresp,   // 
    input  logic [ 63:0 ] i_rdata,   // +
    input  logic 	      i_rlast    // +

);
    logic s_wlast;

    //---------------------------
    // Continious assignments.
    //---------------------------
    assign o_read_data = i_rdata;
    assign o_arlen     = i_axi_len;
    assign o_arsize    = i_axi_size;
    assign o_arburst   = i_axi_burst;
    assign o_awlen     = i_axi_len;
    assign o_awsize    = i_axi_size;
    assign o_awburst   = i_axi_burst;
    assign o_wdata     = i_write_data;

    //-------------------------
    // Write FSM.
    //-------------------------

    // FSM: States.
    typedef enum logic [ 2:0 ] {
        IDLE      = 3'b000,
        AW_WRITE  = 3'b001,
        WRITE     = 3'b010,
        BRESP     = 3'b011,
        AR_READ   = 3'b100,
        READ      = 3'b101
    } t_state;

    t_state PS;
    t_state NS;

    // FSM: State Synchronization 
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) begin
            PS <= IDLE;
        end
        else PS <= NS;
    end

    // FSM: Next State Logic.
    always_comb begin
        NS = PS;

        case ( PS )
            IDLE    : if ( i_write_req           ) NS = AW_WRITE;
                 else if ( i_read_req            ) NS = AR_READ;
            AW_WRITE: if ( o_awvalid & i_awready ) NS = WRITE;
            WRITE   : if ( o_wlast & i_wready    ) NS = BRESP;
            BRESP   : if ( i_bvalid & o_bready   ) NS = IDLE;
            AR_READ : if ( o_arvalid & i_arready ) NS = READ;
            READ    : if ( s_rlast               ) NS = IDLE;
            default : NS = PS;
        endcase

    end

    // FSM: Output Logic.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            o_awvalid <= 1'b0;
            o_awid    <= '0;
            o_awaddr  <= '0;

            o_wvalid  <= 1'b0;
            o_wstrb   <= '0;

            o_bready  <= 1'b0;

            o_arvalid <= 1'b0;
            o_arid    <= '0;
            o_araddr  <= '0;

            o_rready  <= 1'b0;
        end

        else begin
            
        
            case ( PS )
                IDLE: begin
                    o_awvalid <= 1'b0;
                    o_awaddr  <= '0;
        
                    o_wvalid  <= 1'b0;
                    o_wstrb   <= i_axi_strb;
        
                    o_bready  <= 1'b0;
        
                    o_arvalid <= 1'b0;
                    o_araddr  <= '0;
        
                    o_rready  <= 1'b0;
    
                    if ( i_write_req ) begin
                        o_awvalid <= 1'b1;
                        o_awaddr  <= i_addr;
                    end
                    else if  ( i_read_req ) begin
                        o_arvalid <= 1'b1;
                        o_araddr  <= i_addr; 
                    end 
                end
    
                AW_WRITE: begin
                    if ( i_awready ) o_awvalid <= 1'b0;
                    o_wvalid  <= 1'b1;
                end 
    
                WRITE: begin
                    if ( o_wlast & i_wready ) begin
                        o_wvalid <= 1'b0;
                        o_bready <= 1'b1;
                    end
                end 
    
                BRESP: if ( i_bvalid ) begin 
                    o_bready <= 1'b0;
                    o_awid   <= o_awid + 4'b1;
                end
    
                AR_READ: begin
                    if ( i_arready ) o_arvalid <= 1'b0;
                    o_rready  <= 1'b1;
                end
    
                READ: if ( s_rlast ) begin
                    o_rready  <= 1'b0; 
                    o_arid    <= o_arid + 4'b1; 
                end
                  
                default: begin
                    o_awvalid <= 1'b0;
                    o_awid    <= '0;
                    o_awaddr  <= '0;
    
                    o_wvalid  <= 1'b0;
                    o_wstrb   <= '0;
    
                    o_bready  <= 1'b0;
    
                    o_arvalid <= 1'b0;
                    o_arid    <= '0;
                    o_araddr  <= '0;
        
                    o_rready  <= 1'b0;
                end
            endcase
        end
    end


    // o_wlast calculation.

    logic [ 7:0 ] s_count;
    always_ff @( posedge clk ) begin
        if      ( PS == AW_WRITE ) s_count <= i_axi_len + 8'd0;
        else if ( i_wready & o_wvalid            ) s_count <= s_count - 8'b1;
    end

    assign s_wlast = ( s_count == 8'b0 ) & ( PS == WRITE );
    assign o_wlast = s_wlast | ( ( i_axi_len == 8'b0 ) & ( PS == WRITE ) );

    assign o_axi_done = ( ( i_bvalid ) & ( i_bresp == 2'b0 ) & ( o_bready ) ) | ( ( s_rlast ) );
    assign o_axi_handshake = ( i_wready & o_wvalid ) | ( o_rready & i_rvalid );

    logic s_rlast;
    always_ff @( posedge clk ) begin
        s_rlast <= i_rlast;
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------
// This module facilitates the data transfer between cache and AXI interfaces.
// -----------------------------------------------------------------------------

module ysyx_201979054_cache_data_transfer 
#(
    parameter AXI_DATA_WIDTH = 32,
              AXI_ADDR_WIDTH = 64,
              BLOCK_WIDTH    = 512,
              COUNT_LIMIT    = 4'b1111,
              COUNT_TO       = 16,
              ADDR_INCR_VAL  = 64'd4
) 
(
    // Control signals.
    input  logic                          clk,
    input  logic                          arst,

    // Input interface.
    input  logic                          i_start_read,
    input  logic                          i_start_write,
    input  logic                          i_axi_done,
    input  logic [ BLOCK_WIDTH    - 1:0 ] i_data_block_cache,
    input  logic [ AXI_DATA_WIDTH - 1:0 ] i_data_axi,
    input  logic [ AXI_ADDR_WIDTH - 1:0 ] i_addr_cache,

    // Output interface.
    output logic                          o_count_done,
    output logic [ BLOCK_WIDTH    - 1:0 ] o_data_block_cache,
    output logic [ AXI_DATA_WIDTH - 1:0 ] o_data_axi,
    output logic [ AXI_ADDR_WIDTH - 1:0 ] o_addr_axi
);

    //------------------------
    // INTERNAL NETS.
    //------------------------
    logic s_start;

    assign s_start = i_start_read | i_start_write;

    //-----------------------------------
    // Lower-level module instantiations.
    //-----------------------------------

    // Counter module instance.
    ysyx_201979054_counter # (
        .LIMIT ( COUNT_LIMIT ), 
        .SIZE  ( COUNT_TO    )  
    ) COUNT0 (
        .clk      ( clk          ),
        .arst     ( arst         ),
        .run      ( i_axi_done   ),
        .restartn ( s_start      ),
        .o_done   ( o_count_done )
    );

    // Address increment module instance.
    ysyx_201979054_addr_increment # (
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .INCR_VAL       ( ADDR_INCR_VAL  )
    ) ADD_INC0 (
        .clk    ( clk          ),
        .arst   ( arst         ),
        .run    ( s_start      ),
        .enable ( i_axi_done   ),
        .i_addr ( i_addr_cache ),
        .o_addr ( o_addr_axi   )
    );

    // FIFO module instance.
    ysyx_201979054_fifo # (
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .FIFO_WIDTH     ( BLOCK_WIDTH    )
    ) FIFO0 (
        .clk          ( clk                ),
        .arst         ( arst               ),
        .write_en     ( i_axi_done         ),
        .start_write  ( i_start_write      ),
        .start_read   ( i_start_read       ),
        .i_data       ( i_data_axi         ),
        .i_data_block ( i_data_block_cache ),
        .o_data       ( o_data_axi         ),
        .o_data_block ( o_data_block_cache )
    );
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------
// This is a nonarchitectural register with write enable signal.
// -------------------------------------------------------------

module ysyx_201979054_clint_mmio 
#(
    parameter REG_WIDTH = 64
) 
(
    input  logic                     clk,
    input  logic                     arst,
    input  logic                     write_en,
    input  logic [             1:0 ] i_addr,
    input  logic [ REG_WIDTH - 1:0 ] i_data,
    output logic [ REG_WIDTH - 1:0 ] o_data,
    output logic                     o_timer_int_call,
    output logic                     o_software_int_call
);


    logic [ REG_WIDTH - 1:0 ] msip;
    logic [ REG_WIDTH - 1:0 ] mtime;
    logic [ REG_WIDTH - 1:0 ] mtimecmp;

    logic [ REG_WIDTH - 1:0 ] mem [ 3 :0 ];

    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            mem [ 0 ] <= '0; // MSIP.
            mem [ 1 ] <= '0; // MTIME
            mem [ 2 ] <= '0; // MTIMECMP.
            mem [ 3 ] <= '0; // Reserved.
        end
        else begin
            mem [ 1 ] <= mem [ 1 ] + 64'b1;
            
            if ( write_en ) mem [ i_addr ] <= i_data;
        end
    end

    assign msip     = mem [ 0 ]; 
    assign mtime    = mem [ 1 ];
    assign mtimecmp = mem [ 2 ];

    assign o_timer_int_call     = ( mtime >= mtimecmp );
    assign o_software_int_call  = ( msip != '0 );

    assign o_data = mem [ i_addr ];
    
endmodule
/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------------------------------
// This is a main control unit that instantiates control fsm, alu and instr decoders to 
//  controls all the control signals based on instruction input. 
// -------------------------------------------------------------------------------------

module  ysyx_201979054_control_unit   
// Port decleration. 
(
    // Common clock & reset.
    input  logic       clk,
    input  logic       arst,

    // Input interface. 
    input  logic [ 2:0] i_instr_22_20,
    input  logic [ 6:0] i_op,
    input  logic [ 2:0] i_func_3,
    input  logic [ 2:0] i_func7_6_4,
    input  logic [ 1:0] i_func7_1_0, 
    input  logic        i_pred_0,
    input  logic        i_zero_flag,
    input  logic        i_slt_flag,
    input  logic        i_sltu_flag,
    input  logic        i_instr_hit,
    input  logic        i_read_last_axi,
    input  logic        i_data_hit,
    input  logic        i_data_dirty,
    input  logic        i_b_resp_axi,
    input  logic        i_instr_addr_ma,
    input logic         i_store_addr_ma,
    input logic         i_load_addr_ma,
    input logic         i_illegal_instr_load,
    input logic         i_timer_int,
    input logic         i_software_int,
    input  logic        i_cacheable_flag,
    input  logic        i_clint_mmio_flag,
    input  logic        i_done_fence,

    // Output interface.
    output logic [ 4:0] o_alu_control,
    output logic [ 2:0] o_result_src,
    output logic [ 1:0] o_alu_src_1,
    output logic [ 1:0] o_alu_src_2,
    output logic [ 2:0] o_imm_src,
    output logic        o_reg_write_en,
    output logic        o_pc_write,
    output logic        o_instr_write_en,
    output logic        o_mem_write_en,
    output logic        o_instr_cache_write_en,
    output logic        o_start_read_axi,
    output logic        o_block_write_en,
    output logic        o_data_valid_update,
    output logic        o_data_lru_update,
    output logic        o_start_write_axi,
    output logic        o_addr_control,
    output logic        o_mem_reg_we,
    output logic        o_fetch_state,
    output logic        o_reg_mem_addr_we,
    output logic        o_start_read_nc,
    output logic        o_start_write_nc,
    output logic        o_invalidate_instr,
    output logic        o_write_en_clint,
    output logic        o_mret_instr,
    output logic        o_interrupt,
    output logic        o_done_wb,
    output logic        o_start_wb,
    output logic        o_csr_writable,
    output logic [ 3:0] o_mcause,
    output logic        o_csr_we_1,
    output logic        o_csr_we_2,
    output logic        o_csr_reg_we,
    output logic [ 2:0] o_csr_write_addr_1,
    output logic [ 2:0] o_csr_write_addr_2,
    output logic [ 2:0] o_csr_read_addr

); 

    // Main FSM.
    logic       s_instr_branch;
    logic       s_branch;
    logic       s_pc_update;
    logic [2:0] s_alu_op;
    
    // Instruction cache.
    logic s_stall_instr;
    logic s_start_instr_cache;
    logic s_start_read_instr;

    // Data cache.
    logic s_stall_data;
    logic s_start_read_data;
    logic s_start_data_cache;

    // Illegalal instruction flag.
    logic s_illegal_instr_alu;
    logic s_illegal_instr_alu_ff;

    logic s_icache_in_idle;

    logic s_start_wb;

    assign o_start_wb = s_start_wb;

    assign o_pc_write       = s_pc_update | ( s_branch );

    assign o_start_read_axi = s_start_read_data | s_start_read_instr;

    // Branch type decoder. 
    always_comb begin : BRANCH_TYPE
        case ( i_func_3 )
            3'b000: s_branch = s_instr_branch & i_zero_flag;        // BEQ instruction.
            3'b001: s_branch = s_instr_branch & (~i_zero_flag);     // BNE instruction.
            3'b100: s_branch = s_instr_branch & i_slt_flag;    // BLT instruction.
            3'b101: s_branch = s_instr_branch & (~i_slt_flag); // BGE instruction.
            3'b110: s_branch = s_instr_branch & i_sltu_flag;    // BLTU instruction. i_negative_flag calculation is different in ALU.
            3'b111: s_branch = s_instr_branch & (~i_sltu_flag); // BGEU instruction. i_negative_flag calculation is different in ALU.

            default: s_branch = 1'b0;
        endcase
    end

    //-------------------------------------
    // Modulle Instantiations.
    //-------------------------------------

    // Main FSM module instance. 
    ysyx_201979054_main_fsm M_FSM (
        .clk                  ( clk                    ),
        .arst                 ( arst                   ),
        .i_instr_22_20        ( i_instr_22_20          ),
        .i_op                 ( i_op                   ),
        .i_func_3             ( i_func_3               ),
        .i_func_7_4           ( i_func7_6_4[0]         ),
        .i_func_7_0           ( i_func7_1_0[0]         ), 
        .i_func_7_1           ( i_func7_1_0[1]         ),
        .i_func_7_6           ( i_func7_6_4[2]         ),
        .i_pred_0             ( i_pred_0               ),
        .i_stall_instr        ( s_stall_instr          ),
        .i_stall_data         ( s_stall_data           ),
        .i_instr_addr_ma      ( i_instr_addr_ma        ),
        .i_store_addr_ma      ( i_store_addr_ma        ),
        .i_load_addr_ma       ( i_load_addr_ma         ),
        .i_illegal_instr_load ( i_illegal_instr_load   ),
        .i_illegal_instr_alu  ( s_illegal_instr_alu_ff ),
        .i_timer_int          ( i_timer_int            ),
        .i_software_int       ( i_software_int         ),
        .i_cacheable_flag     ( i_cacheable_flag       ),
        .i_done_axi           ( i_read_last_axi        ),
        .i_clint_mmio_flag    ( i_clint_mmio_flag      ),
        .i_icache_idle        ( s_icache_in_idle       ),
        .i_done_fence         ( i_done_fence           ),
        .o_alu_op             ( s_alu_op               ),
        .o_result_src         ( o_result_src           ),
        .o_alu_src_1          ( o_alu_src_1            ),
        .o_alu_src_2          ( o_alu_src_2            ),
        .o_reg_write_en       ( o_reg_write_en         ),
        .o_pc_update          ( s_pc_update            ),
        .o_mem_write_en       ( o_mem_write_en         ),
        .o_instr_write_en     ( o_instr_write_en       ),
        .o_start_i_cache      ( s_start_instr_cache    ),
        .o_start_d_cache      ( s_start_data_cache     ),
        .o_branch             ( s_instr_branch         ),
        .o_mem_reg_we         ( o_mem_reg_we           ),
        .o_fetch_state        ( o_fetch_state          ),
        .o_reg_mem_addr_we    ( o_reg_mem_addr_we      ),
        .o_start_read_nc      ( o_start_read_nc        ),
        .o_start_write_nc     ( o_start_write_nc       ),
        .o_invalidate_instr   ( o_invalidate_instr     ),
        .o_write_en_clint     ( o_write_en_clint       ),
        .o_mret_instr         ( o_mret_instr           ),
        .o_interrupt          ( o_interrupt            ),
        .o_start_wb           ( s_start_wb             ),
        .o_csr_writable       ( o_csr_writable         ),
        .o_mcause             ( o_mcause               ),
        .o_csr_we_1           ( o_csr_we_1             ),
        .o_csr_we_2           ( o_csr_we_2             ),
        .o_csr_reg_we         ( o_csr_reg_we           ),
        .o_csr_write_addr_1   ( o_csr_write_addr_1     ),
        .o_csr_write_addr_2   ( o_csr_write_addr_2     ),
        .o_csr_read_addr      ( o_csr_read_addr        )
    );

    // Instruction cache FSM.
    ysyx_201979054_instr_cache_fsm I_C_FSM (
        .clk              ( clk                    ),
        .arst             ( arst                   ),
        .i_start_check    ( s_start_instr_cache    ),
        .i_hit            ( i_instr_hit            ),
        .i_r_last         ( i_read_last_axi        ),
        .o_stall          ( s_stall_instr          ),
        .o_instr_write_en ( o_instr_cache_write_en ),
        .o_start_read     ( s_start_read_instr     ),
        .o_in_idle        ( s_icache_in_idle       )
    );

    // Data cache FSM.
    ysyx_201979054_data_cache_fsm D_C_FSM (
        .clk                   ( clk                 ),
        .arst                  ( arst                ),
        .i_start_check         ( s_start_data_cache  ),
        .i_hit                 ( i_data_hit          ),
        .i_dirty               ( i_data_dirty        ),
        .i_r_last              ( i_read_last_axi     ),
        .i_b_resp              ( i_b_resp_axi        ),
        .i_start_wb            ( s_start_wb          ),
        .o_stall               ( s_stall_data        ),
        .o_data_block_write_en ( o_block_write_en    ),
        .o_valid_update        ( o_data_valid_update ),
        .o_lru_update          ( o_data_lru_update   ),
        .o_start_write         ( o_start_write_axi   ),
        .o_start_read          ( s_start_read_data   ),
        .o_addr_control        ( o_addr_control      ),
        .o_done_wb             ( o_done_wb           )
    );


    // ALU decoder module.
    ysyx_201979054_alu_decoder ALU_DECODER (
        .i_alu_op        ( s_alu_op            ),
        .i_func_3        ( i_func_3            ),
        .i_func_7_5      ( i_func7_6_4[1]      ),
        .i_op_5          ( i_op[5]             ),
        .o_alu_control   ( o_alu_control       ),
        .o_illegal_instr ( s_illegal_instr_alu )
    );

    // Instruction decoder. 
    ysyx_201979054_instr_decoder INSTR_DECODER (
        .i_op      ( i_op      ),
        .o_imm_src ( o_imm_src )
    );

    // Illegal instruction flag flip-flop.
    ysyx_201979054_register # (.DATA_WIDTH (1) ) II_ALU_FF (
        .clk          ( clk                    ),
        .arst         ( arst                   ),
        .i_write_data ( s_illegal_instr_alu    ),
        .o_read_data  ( s_illegal_instr_alu_ff )
    );

endmodule
/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// --------------------------------------------------------------------------------------------------------
// This is a counter module that counts the number of transferred data bursts through AXI4-Lite interface.
// --------------------------------------------------------------------------------------------------------

module ysyx_201979054_counter 
#(
    parameter LIMIT          = 4'b1111,
              SIZE           = 16 
) 
(   
    // Countrol logic
    input  logic clk,
    input  logic arst,
    input  logic run,
    input  logic restartn,

    // Output interface.
    output logic o_done
);

    logic [ $clog2( SIZE ) - 1:0 ] s_count;

    always_ff @( posedge clk, posedge arst ) begin
        if      ( arst      ) s_count <= '0;
        else if ( ~restartn ) s_count <= '0;
        else if ( run       ) s_count <= s_count + 4'b1; 
    end

    always_ff @( posedge clk, posedge arst ) begin
        if      ( arst                      ) o_done <= 1'b0;
        else if ( (s_count == LIMIT ) & run ) o_done <= 1'b1;
        else                                  o_done <= 1'b0;
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ---------------------------------------------------------------------------------------
// This is a top CPU module.
// ---------------------------------------------------------------------------------------

module ysyx_201979054 (
    input clock,
    input reset,
    input io_interrupt,
    input io_master_awready,
    output io_master_awvalid,
    output [3:0] io_master_awid,
    output [31:0] io_master_awaddr,
    output [7:0] io_master_awlen,
    output [2:0] io_master_awsize,
    output [1:0] io_master_awburst,
    input io_master_wready,
    output io_master_wvalid,
    output [63:0] io_master_wdata,
    output [7:0] io_master_wstrb,
    output io_master_wlast,
    output io_master_bready,
    input io_master_bvalid,
    input [3:0] io_master_bid,
    input [1:0] io_master_bresp,
    input io_master_arready,
    output io_master_arvalid,
    output [3:0] io_master_arid,
    output [31:0] io_master_araddr,
    output [7:0] io_master_arlen,
    output [2:0] io_master_arsize,
    output [1:0] io_master_arburst,
    output io_master_rready,
    input io_master_rvalid,
    input [3:0] io_master_rid,
    input [1:0] io_master_rresp,
    input [63:0] io_master_rdata,
    input io_master_rlast,
    output io_slave_awready,
    input io_slave_awvalid,
    input [3:0] io_slave_awid,
    input [31:0] io_slave_awaddr,
    input [7:0] io_slave_awlen,
    input [2:0] io_slave_awsize,
    input [1:0] io_slave_awburst,
    output io_slave_wready,
    input io_slave_wvalid,
    input [63:0] io_slave_wdata,
    input [7:0] io_slave_wstrb,
    input io_slave_wlast,
    input io_slave_bready,
    output io_slave_bvalid,
    output [3:0] io_slave_bid,
    output [1:0] io_slave_bresp,
    output io_slave_arready,
    input io_slave_arvalid,
    input [3:0] io_slave_arid,
    input [31:0] io_slave_araddr,
    input [7:0] io_slave_arlen,
    input [2:0] io_slave_arsize,
    input [1:0] io_slave_arburst,
    input io_slave_rready,
    output io_slave_rvalid,
    output [3:0] io_slave_rid,
    output [1:0] io_slave_rresp,
    output [63:0] io_slave_rdata,
    output io_slave_rlast,
    output [5:0] io_sram0_addr,
    output io_sram0_cen,
    output io_sram0_wen,
    output [127:0] io_sram0_wmask,
    output [127:0] io_sram0_wdata,
    input [127:0] io_sram0_rdata,
    output [5:0] io_sram1_addr,
    output io_sram1_cen,
    output io_sram1_wen,
    output [127:0] io_sram1_wmask,
    output [127:0] io_sram1_wdata,
    input [127:0] io_sram1_rdata,
    output [5:0] io_sram2_addr,
    output io_sram2_cen,
    output io_sram2_wen,
    output [127:0] io_sram2_wmask,
    output [127:0] io_sram2_wdata,
    input [127:0] io_sram2_rdata,
    output [5:0] io_sram3_addr,
    output io_sram3_cen,
    output io_sram3_wen,
    output [127:0] io_sram3_wmask,
    output [127:0] io_sram3_wdata,
    input [127:0] io_sram3_rdata,
    output [5:0] io_sram4_addr,
    output io_sram4_cen,
    output io_sram4_wen,
    output [127:0] io_sram4_wmask,
    output [127:0] io_sram4_wdata,
    input [127:0] io_sram4_rdata,
    output [5:0] io_sram5_addr,
    output io_sram5_cen,
    output io_sram5_wen,
    output [127:0] io_sram5_wmask,
    output [127:0] io_sram5_wdata,
    input [127:0] io_sram5_rdata,
    output [5:0] io_sram6_addr,
    output io_sram6_cen,
    output io_sram6_wen,
    output [127:0] io_sram6_wmask,
    output [127:0] io_sram6_wdata,
    input [127:0] io_sram6_rdata,
    output [5:0] io_sram7_addr,
    output io_sram7_cen,
    output io_sram7_wen,
    output [127:0] io_sram7_wmask,
    output [127:0] io_sram7_wdata,
    input [127:0] io_sram7_rdata
);

    //--------------------------------
    // Internal nets.
    //--------------------------------
    logic arst;

    logic s_write_req;
    logic s_read_req;
    logic s_read_req_non_cacheable;
    logic s_write_req_non_cacheable;

    logic [ 511:0 ] s_data_block_write_top;
    logic [ 511:0 ] s_data_block_read_top;
    logic [ 511:0 ] s_data_block_read_top_axi4;
    logic [ 511:0 ] s_data_block_read_top_apb;
    logic [  63:0 ] s_data_non_cacheable_r;
    logic [   7:0 ] s_data_non_cacheable_w;
    logic [  31:0 ] s_addr;
    logic [  31:0 ] s_addr_non_cacheable;
    logic [  31:0 ] s_addr_calc;
    logic [  31:0 ] s_addr_calc_apb;

    logic [ 31:0 ] s_read_axi_fifo;
    logic [ 63:0 ] s_write_axi_fifo;
    logic [ 63:0 ] s_write_axi_fifo_axi4;
    logic [ 31:0 ] s_write_axi_fifo_apb;

    logic [ 31:0 ] s_addr_axi;
    logic [ 63:0 ] s_write_axi;
    logic [ 63:0 ] s_read_axi;
    logic [  7:0 ] s_reg_read_axi;

    logic s_axi_done;
    logic s_axi_handshake;


    logic s_start_read_axi;
    logic s_start_read_axi_cache;
    logic s_start_write_axi;
    logic s_start_write_axi_cache;

    logic s_count_done;
    logic s_count_done_apb;
    logic s_done;

    logic [ 2:0 ] s_axi_size;
    logic [ 2:0 ] s_axi_size_cache;
    logic [ 7:0 ] s_axi_strb;
    logic [ 7:0 ] s_axi_strb_cache;
    logic [ 7:0 ] s_axi_len;

    logic s_axi4_access;

    assign s_axi4_access = ( s_addr >= 32'h4000_0000 );

    assign s_axi_strb_cache      = s_axi4_access ? 8'hFF : 8'h0F;
    assign s_axi_size_cache      = s_axi4_access ? 3'b11 : 3'b10;
    assign s_write_axi_fifo      = s_axi4_access ? s_write_axi_fifo_axi4 : { s_write_axi_fifo_apb, s_write_axi_fifo_apb };
    assign s_addr_calc           = s_axi4_access ? s_addr : s_addr_calc_apb;
    assign s_data_block_read_top = s_axi4_access ? s_data_block_read_top_axi4 : s_data_block_read_top_apb;


    assign s_count_done = s_count_done_apb;

    assign s_start_read_axi_cache  = s_read_req  & ( ~ s_count_done );
    assign s_start_read_axi        = s_read_req_non_cacheable | s_start_read_axi_cache;
    assign s_start_write_axi_cache = s_write_req & ( ~ s_count_done );
    assign s_start_write_axi       = s_write_req_non_cacheable | s_start_write_axi_cache;
    
    assign s_addr_axi      = ( s_read_req_non_cacheable | s_write_req_non_cacheable ) ? s_addr_non_cacheable : s_addr_calc;
    assign s_axi_size      = ( s_read_req_non_cacheable | s_write_req_non_cacheable ) ? 3'b00 : s_axi_size_cache;
    assign s_axi_strb      = s_write_req_non_cacheable  ? 8'h01 : s_axi_strb_cache;
    assign s_axi_len       = s_axi4_access ? 8'b111 : 8'b000;

    assign s_read_axi_fifo        = s_read_axi [ 31:0 ];
    assign s_data_non_cacheable_r = { 56'b0 , s_reg_read_axi };
    assign s_write_axi            = s_write_req_non_cacheable ? { 8 { s_data_non_cacheable_w } } : s_write_axi_fifo;

    assign s_done = ( s_count_done ) | ( s_axi_done & ( s_read_req_non_cacheable | s_write_req_non_cacheable ) ) | ( s_axi4_access & s_axi_done ); 



    //-----------------------------------
    // LOWER LEVEL MODULE INSTANTIATIONS.
    //-----------------------------------

    //------------------------------
    // Reset Synchronizer Instance.
    //------------------------------
    ysyx_201979054_reset_sync RST_SYNC (
        .clk       ( clock ),
        .arst      ( reset ),
        .arst_sync ( arst  )
    );



    //-----------------------------
    // Top datapath unit instance.
    //-----------------------------
    ysyx_201979054_datapath TOP0 (
        .clk                  ( clock                     ),
        .arst                 ( arst                      ),
        .i_done_axi           ( s_done                    ),
        .i_data_read_axi      ( s_data_block_read_top     ),
        .i_data_non_cacheable ( s_data_non_cacheable_r    ),
        .o_data_non_cacheable ( s_data_non_cacheable_w    ),
        .o_start_read_axi     ( s_read_req                ),
        .o_start_read_axi_nc  ( s_read_req_non_cacheable  ),
        .o_start_write_axi_nc ( s_write_req_non_cacheable ),
        .o_start_write_axi    ( s_write_req               ),
        .o_addr               ( s_addr                    ),
        .o_addr_non_cacheable ( s_addr_non_cacheable      ),
        .o_data_write_axi     ( s_data_block_write_top    )
    );



    //-----------------------
    // AXI4 Master Instance.
    //-----------------------
    ysyx_201979054_axi4_master AXI4_M0 (
        .clk          ( clock             ),
        .arst         ( arst              ),
        .io_interrupt ( io_interrupt      ),
        .i_write_req  ( s_start_write_axi ),
        .i_read_req   ( s_start_read_axi  ),
        .i_addr       ( s_addr_axi        ),
        .i_write_data ( s_write_axi       ),
        .i_axi_len    ( s_axi_len         ),
        .i_axi_size   ( s_axi_size        ), 
        .i_axi_burst  ( 2'b01             ), 
        .i_axi_strb   ( s_axi_strb        ), 
        .o_read_data  ( s_read_axi        ),
        .o_axi_done   ( s_axi_done        ),
        .o_axi_handshake ( s_axi_handshake ),
        .i_awready    ( io_master_awready ),
        .o_awvalid    ( io_master_awvalid ),
        .o_awid       ( io_master_awid    ),
        .o_awaddr     ( io_master_awaddr  ),
        .o_awlen      ( io_master_awlen   ),
        .o_awsize     ( io_master_awsize  ),
        .o_awburst    ( io_master_awburst ),
        .i_wready     ( io_master_wready  ),
        .o_wvalid     ( io_master_wvalid  ),
        .o_wdata      ( io_master_wdata   ),
        .o_wstrb      ( io_master_wstrb   ), 
        .o_wlast      ( io_master_wlast   ),
        .o_bready     ( io_master_bready  ),
        .i_bvalid     ( io_master_bvalid  ),
        .i_bid        ( io_master_bid     ),
        .i_bresp      ( io_master_bresp   ),
        .i_arready    ( io_master_arready ),
        .o_arvalid    ( io_master_arvalid ),
        .o_arid       ( io_master_arid    ),
        .o_araddr     ( io_master_araddr  ),
        .o_arlen      ( io_master_arlen   ),
        .o_arsize     ( io_master_arsize  ),
        .o_arburst    ( io_master_arburst ),
        .o_rready     ( io_master_rready  ),
        .i_rvalid     ( io_master_rvalid  ),
        .i_rid        ( io_master_rid     ),
        .i_rresp      ( io_master_rresp   ),
        .i_rdata      ( io_master_rdata   ),
        .i_rlast      ( io_master_rlast   )
    );


    //-------------------------------------------
    // Cache data transfer unit instance for APB.
    //-------------------------------------------
    ysyx_201979054_cache_data_transfer # (
        .AXI_DATA_WIDTH ( 32      ),
        .AXI_ADDR_WIDTH ( 32      ),
        .BLOCK_WIDTH    ( 512     ),
        .COUNT_LIMIT    ( 4'b1111 ),
        .COUNT_TO       ( 16      ),
        .ADDR_INCR_VAL  ( 32'd4   ) 
    ) DATA_T_APB (
        .clk                ( clock                     ),
        .arst               ( arst                      ),
        .i_start_read       ( s_start_read_axi_cache & ( ~s_axi4_access )    ),
        .i_start_write      ( s_start_write_axi_cache & ( ~s_axi4_access )   ),
        .i_axi_done         ( s_axi_handshake                ),
        .i_data_block_cache ( s_data_block_write_top    ),
        .i_data_axi         ( s_read_axi_fifo           ),
        .i_addr_cache       ( s_addr [ 31:0 ]           ),
        .o_count_done       ( s_count_done_apb          ),
        .o_data_block_cache ( s_data_block_read_top_apb ),
        .o_data_axi         ( s_write_axi_fifo_apb      ),
        .o_addr_axi         ( s_addr_calc_apb           )
    );


    //--------------------------------------------------------
    // FIFO for accumilating the data coming from AXI4 burst.
    //--------------------------------------------------------
    ysyx_201979054_fifo # (
        .AXI_DATA_WIDTH ( 64  ),
        .FIFO_WIDTH     ( 512 )
    ) FIFO_0 (
        .clk          ( clock                                       ),
        .arst         ( arst                                        ),
        .write_en     ( s_axi_handshake                             ),
        .start_read   ( s_start_read_axi_cache  & ( s_axi4_access ) ),
        .start_write  ( s_start_write_axi_cache & ( s_axi4_access ) ),
        .i_data       ( s_read_axi                                  ),
        .i_data_block ( s_data_block_write_top                      ),
        .o_data       ( s_write_axi_fifo_axi4                       ),
        .o_data_block ( s_data_block_read_top_axi4                  )
    );


    //-------------------------
    // Memory Data Register. 
    //-------------------------
    ysyx_201979054_register_en #( .DATA_WIDTH(8) ) REG_AXI_DATA (
        .clk          ( clock           ),
        .arst         ( arst            ),
        .write_en     ( s_axi_handshake ),
        .i_write_data ( s_read_axi[7:0] ),
        .o_read_data  ( s_reg_read_axi  )
    );


    //---------------------------------------------
    // Redundant outputs.
    //---------------------------------------------
    assign io_slave_awready = '0;
    assign io_slave_wready = '0;
    assign io_slave_bvalid = '0;
    assign io_slave_bid = '0;
    assign io_slave_bresp = '0;
    assign io_slave_arready = '0;
    assign io_slave_rvalid = '0;
    assign io_slave_rid = '0;
    assign io_slave_rresp = '0;
    assign io_slave_rdata = '0;
    assign io_slave_rlast = '0;
    assign io_sram0_addr = '0;
    assign io_sram0_cen = '0;
    assign io_sram0_wen = '0;
    assign io_sram0_wmask = '0;
    assign io_sram0_wdata = '0;
    assign io_sram1_addr = '0;
    assign io_sram1_cen = '0;
    assign io_sram1_wen = '0;
    assign io_sram1_wmask = '0;
    assign io_sram1_wdata = '0;
    assign io_sram2_addr = '0;
    assign io_sram2_cen = '0;
    assign io_sram2_wen = '0;
    assign io_sram2_wmask = '0;
    assign io_sram2_wdata = '0;
    assign io_sram3_addr = '0;
    assign io_sram3_cen = '0;
    assign io_sram3_wen = '0;
    assign io_sram3_wmask = '0;
    assign io_sram3_wdata = '0;
    assign io_sram4_addr = '0;
    assign io_sram4_cen = '0;
    assign io_sram4_wen = '0;
    assign io_sram4_wmask = '0;
    assign io_sram4_wdata = '0;
    assign io_sram5_addr = '0;
    assign io_sram5_cen = '0;
    assign io_sram5_wen = '0;
    assign io_sram5_wmask = '0;
    assign io_sram5_wdata = '0;
    assign io_sram6_addr = '0;
    assign io_sram6_cen = '0;
    assign io_sram6_wen = '0;
    assign io_sram6_wmask = '0;
    assign io_sram6_wdata = '0;
    assign io_sram7_addr = '0;
    assign io_sram7_cen = '0;
    assign io_sram7_wen = '0;
    assign io_sram7_wmask = '0;
    assign io_sram7_wdata = '0;
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------
// This is a csr file component of processor based on RISC-V architecture.
// ----------------------------------------------------------------------------

module ysyx_201979054_csr_file
// Parameters.
#(
    parameter DATA_WIDTH = 64,
              ADDR_WIDTH = 3,
              REG_DEPTH  = 8
)
// Port decleration. 
(   
    // Common clock & enable signal.
    input  logic                      clk,
    input  logic                      write_en_1,
    input  logic                      write_en_2,
    input  logic                      arst,

    //Input interface. 
    input  logic [ ADDR_WIDTH - 1:0 ] i_read_addr,
    input  logic [ ADDR_WIDTH - 1:0 ] i_write_addr_1,
    input  logic [ ADDR_WIDTH - 1:0 ] i_write_addr_2,
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data_1,
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data_2,
    input  logic                      i_timer_int_call,
    input  logic                      i_software_int_call,
    input  logic                      i_interrupt_jump,
    input  logic                      i_mret_instr,
    input  logic                      i_writable,
    
    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_read_data,
    output logic                      o_mie_mstatus,
    output logic                      o_mtip_mip,
    output logic                      o_msip_mip,
    output logic                      o_mtie_mie,
    output logic                      o_msie_mie
);

    // Register block.
    logic [ DATA_WIDTH - 1:0 ] mem           [ REG_DEPTH - 1:0 ];
    logic [ DATA_WIDTH - 1:0 ] csr_read_only [             3:0 ];

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) begin
            mem[ 0 ] <= '0; // Mstatus.
            mem[ 1 ] <= '0; // Reserved.
            mem[ 2 ] <= '0; // Mie.
            mem[ 3 ] <= '0; // Mtvec.
            mem[ 4 ] <= '0; // Mcause.
            mem[ 5 ] <= '0; // Mepc.
            mem[ 6 ] <= '0; // Mip.
            mem[ 7 ] <= '0; // Reserved.
        end
        else begin
            if ( i_timer_int_call ) mem[ 6 ][ 7 ] <= 1'b1; // mip MTIP bit set.
            else                    mem[ 6 ][ 7 ] <= 1'b0; // mip MTIP bit clear.

            if ( i_software_int_call ) mem [ 6 ][ 3 ] <= 1'b1; // mip MSIP bit set.
            else                       mem [ 6 ][ 3 ] <= 1'b0; // mip MSIP bit clear.

            if ( i_interrupt_jump ) begin 
                mem[ 0 ][ 3 ] <= 1'b0; // mstatus MIE bit clear.
                mem[ 0 ][ 7 ] <= mem[ 0 ][ 3 ]; // mstatus MPIE = MIE when jump to interrupt handler is taken.
            end

            if ( i_mret_instr     ) mem[ 0 ][ 3 ] <= mem[ 0 ][ 7 ]; // mstatus MIE = MPIE in case of MRET instruction.

            if ( write_en_1 ) begin
                case ( i_write_addr_1 )
                    6: mem [ 6 ] <= { i_write_data_1[ DATA_WIDTH - 1:8 ], i_timer_int_call, i_write_data_1 [ 6:4 ], i_software_int_call, i_write_data_1 [ 2:0 ] };
                    0: if ( i_interrupt_jump ) mem [ 0 ] <= {i_write_data_1[ DATA_WIDTH - 1:1 ], 1'b0 };
                       else                                          mem [ 0 ] <= i_write_data_1;
                    default: mem[ i_write_addr_1 ] <= i_write_data_1;
                endcase
            end
    
            if ( write_en_2 ) begin
                case ( i_write_addr_2 )
                    6: mem [ 6 ] <= { i_write_data_2[ DATA_WIDTH - 1:8 ], i_timer_int_call, i_write_data_2[ 6:4 ], i_software_int_call, i_write_data_2[ 2:0 ] };
                    0: if ( i_interrupt_jump ) mem [ 0 ] <= { i_write_data_2 [ DATA_WIDTH - 1:1 ], 1'b0 };
                       else                                         mem [ 0 ] <= i_write_data_2;
                    default: mem [ i_write_addr_2 ] <= i_write_data_2;
                endcase
            end
        end
    end

    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            csr_read_only [ 0 ] <= '0; // Mhartid.
            csr_read_only [ 1 ] <= 64'h6372_766d; // Mvendorid.
            csr_read_only [ 2 ] <= 64'h0063_6972_6576_616d; // Marchid.
            csr_read_only [ 3 ] <= 64'h0062_672d_656e_7574; // Mimpid.
        end
    end

    // Read logic.
    assign o_read_data   = i_writable ? mem [ i_read_addr ] : csr_read_only [ i_read_addr[1:0] ];
    assign o_mie_mstatus = mem [ 0 ][ 3 ];
    assign o_mtip_mip    = mem [ 6 ][ 7 ];
    assign o_msip_mip    = mem [ 6 ][ 3 ];
    assign o_mtie_mie    = mem [ 2 ][ 7 ];  
    assign o_msie_mie    = mem [ 2 ][ 3 ];  
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------------
// This is a data cache implemented using 2-way set associative cache.
// -------------------------------------------------------------------

module ysyx_201979054_data_cache 
#(
    parameter SET_COUNT      = 2,
              WORD_SIZE      = 32,
              BLOCK_WIDTH    = 512,
              N              = 2,
              ADDR_WIDTH     = 64,
              OUT_ADDR_WIDTH = 32,
              REG_WIDTH      = 64
) 
(
    // Control signals.
    input  logic                          clk,
    input  logic                          arst,
    input  logic                          write_en,
    input  logic                          valid_update,
    input  logic                          lru_update,
    input  logic                          block_write_en,
    
    // Input Interface.
    input  logic [ ADDR_WIDTH     - 1:0 ] i_data_addr,
    input  logic [ REG_WIDTH      - 1:0 ] i_data,
    input  logic [ BLOCK_WIDTH    - 1:0 ] i_data_block,
    input  logic [                  1:0 ] i_store_type,
    input  logic                          i_addr_control,
    input  logic                          i_start_wb,
    input  logic                          i_done_wb,

    // Output Interface.
    output logic [ REG_WIDTH      - 1:0 ] o_data,
    output logic [ BLOCK_WIDTH    - 1:0 ] o_data_block,
    output logic                          o_hit,
    output logic                          o_dirty,
    output logic [ OUT_ADDR_WIDTH - 1:0 ] o_addr_axi,
    output logic                          o_done_fence,
    output logic                          o_store_addr_ma

);  
    //-------------------------
    // Local Parameters.
    //-------------------------
    localparam WORD_COUNT     = BLOCK_WIDTH/WORD_SIZE; // 16 bits.

    localparam WORD_OFFSET_W  = $clog2( WORD_COUNT  ); // 4 bits.
    localparam BLOCK_NUMBER_W = $clog2( SET_COUNT );   // 1 bits.
    localparam BYTE_OFFSET_W  = $clog2( WORD_SIZE/8 ); // 2 bits.

    localparam TAG_MSB         = ADDR_WIDTH - 1;                                 // 63.
    localparam TAG_LSB         = BLOCK_NUMBER_W + WORD_OFFSET_W + BYTE_OFFSET_W; // 7.
    localparam TAG_WIDTH       = TAG_MSB - TAG_LSB + 1;                          // 57
    localparam INDEX_MSB       = TAG_LSB - 1;                                    // 6.
    localparam INDEX_LSB       = WORD_OFFSET_W + BYTE_OFFSET_W;                  // 6.
    localparam WORD_OFFSET_MSB = INDEX_LSB - 1;                                  // 5.
    localparam WORD_OFFSET_LSB = BYTE_OFFSET_W;                                  // 2.



    //------------------------
    // Internal signals.
    //------------------------
    logic [ TAG_MSB         - TAG_LSB        :0 ] s_tag_in;
    logic [ INDEX_MSB       - INDEX_LSB      :0 ] s_index;
    logic [ WORD_OFFSET_MSB - WORD_OFFSET_LSB:0 ] s_word_offset;
    logic [                                 1:0 ] s_byte_offset;

    logic [ $clog2( N ) - 1:0 ] s_lru;
    logic [           N - 1:0 ] s_lru_found;
    logic [           N - 1:0 ] s_hit;

    logic [ OUT_ADDR_WIDTH - 1:0 ] s_addr_wb;
    logic [ OUT_ADDR_WIDTH - 1:0 ] s_addr;
    logic [ OUT_ADDR_WIDTH - 1:0 ] s_addr_axi;

    // Store misalignment signals.
    logic s_store_addr_ma_sh;
    logic s_store_addr_ma_sw;
    logic s_store_addr_ma_sd;



    //-------------------------
    // Continious assignments.
    //-------------------------
    assign s_tag_in      = i_data_addr[ TAG_MSB        :TAG_LSB         ];
    assign s_index       = i_data_addr[ INDEX_MSB      :INDEX_LSB       ]; 
    assign s_word_offset = i_data_addr[ WORD_OFFSET_MSB:WORD_OFFSET_LSB ];
    assign s_byte_offset = i_data_addr[               1:0               ];


    assign s_store_addr_ma_sh = s_byte_offset[0];
    assign s_store_addr_ma_sw = | s_byte_offset;
    assign s_store_addr_ma_sd = s_store_addr_ma_sw | s_word_offset[0];


    //----------------------------------------
    // Store address misaligned calculation.
    //----------------------------------------
    always_comb begin
        case ( i_store_type )
            2'b11: o_store_addr_ma = s_store_addr_ma_sd; // SD instruction.
            2'b10: o_store_addr_ma = s_store_addr_ma_sw; // SW instruction.
            2'b01: o_store_addr_ma = s_store_addr_ma_sh; // SH instruction.
            2'b00: o_store_addr_ma = 1'b0;               // SB instruction.
            default: o_store_addr_ma = 1'b0;
        endcase
    end



    //-------------------------------------
    // Memory
    //-------------------------------------

    // Tag memory.
    logic [ TAG_WIDTH - 1:0 ] tag_mem [ SET_COUNT - 1:0 ][ N - 1:0 ];

    // Valid & Dirty & LRU memories.
    logic [ SET_COUNT   - 1:0 ] valid_mem [ N - 1:0 ];
    logic [ SET_COUNT   - 1:0 ] dirty_mem [ N - 1:0 ];
    logic [ $clog2( N ) - 1:0 ] lru_mem   [ N - 1:0 ][ SET_COUNT - 1:0 ];
    logic [ SET_COUNT   - 1:0 ] lru_set;

    // Data memory.
    logic [ BLOCK_WIDTH - 1:0 ] data_mem [ SET_COUNT - 1:0 ][ N - 1:0 ];



    //------------------------------
    // Check 
    //------------------------------

    // Check for hit.
    logic [ $clog2 (N) - 1:0 ] s_match;
    always_comb begin
        s_hit[0] = valid_mem[ 0 ][ s_index ] & ( tag_mem [ s_index ][ 0 ] == s_tag_in );
        s_hit[1] = valid_mem[ 1 ][ s_index ] & ( tag_mem [ s_index ][ 1 ] == s_tag_in );

        o_hit = | s_hit;

        if ( o_hit ) begin
            casez ( s_hit )
                2'bz1: s_match = 1'b0;
                2'b10: s_match = 1'b1;
                default: s_match = 1'b0;
            endcase  
            
        end
        else s_match = s_lru;
    end

    // Find LRU.
    always_comb begin
        s_lru_found[0] = lru_mem[0][ s_index ] == 1'b0;
        s_lru_found[1] = lru_mem[1][ s_index ] == 1'b0;

        casez ( s_lru_found )
            2'bz1: s_lru = 1'b0;
            2'b10: s_lru = 1'b1;
            default: s_lru = 1'b0;
        endcase  
    end


    //-------------------------
    // Write logic.
    //-------------------------

    // Write data logic.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            data_mem [ 0 ][ 0 ] <= '0;
            data_mem [ 0 ][ 1 ] <= '0;
            data_mem [ 1 ][ 0 ] <= '0;
            data_mem [ 1 ][ 1 ] <= '0;
            tag_mem  [ 0 ][ 0 ] <= '0; 
            tag_mem  [ 0 ][ 1 ] <= '0; 
            tag_mem  [ 1 ][ 0 ] <= '0; 
            tag_mem  [ 1 ][ 1 ] <= '0; 
        end
        else if ( write_en ) begin
            case ( i_store_type )
                // SD Instruction.
                2'b11: begin
                    case ( s_word_offset[3:1] )
                        3'b000:  data_mem[ s_index ][ s_match ][ 63 :0   ] <= i_data; 
                        3'b001:  data_mem[ s_index ][ s_match ][ 127:64  ] <= i_data; 
                        3'b010:  data_mem[ s_index ][ s_match ][ 191:128 ] <= i_data; 
                        3'b011:  data_mem[ s_index ][ s_match ][ 255:192 ] <= i_data; 
                        3'b100:  data_mem[ s_index ][ s_match ][ 319:256 ] <= i_data; 
                        3'b101:  data_mem[ s_index ][ s_match ][ 383:320 ] <= i_data; 
                        3'b110:  data_mem[ s_index ][ s_match ][ 447:384 ] <= i_data; 
                        3'b111:  data_mem[ s_index ][ s_match ][ 511:448 ] <= i_data;
                        default: data_mem[ s_index ][ s_match ][ 63:0    ] <= '0;
                    endcase                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                end

                // SW Instruction.
                2'b10: begin
                    case ( s_word_offset )
                        4'b0000: data_mem[ s_index ][ s_match ][ 31 :0   ] <= i_data[ 31:0 ]; 
                        4'b0001: data_mem[ s_index ][ s_match ][ 63 :32  ] <= i_data[ 31:0 ]; 
                        4'b0010: data_mem[ s_index ][ s_match ][ 95 :64  ] <= i_data[ 31:0 ]; 
                        4'b0011: data_mem[ s_index ][ s_match ][ 127:96  ] <= i_data[ 31:0 ]; 
                        4'b0100: data_mem[ s_index ][ s_match ][ 159:128 ] <= i_data[ 31:0 ]; 
                        4'b0101: data_mem[ s_index ][ s_match ][ 191:160 ] <= i_data[ 31:0 ]; 
                        4'b0110: data_mem[ s_index ][ s_match ][ 223:192 ] <= i_data[ 31:0 ]; 
                        4'b0111: data_mem[ s_index ][ s_match ][ 255:224 ] <= i_data[ 31:0 ]; 
                        4'b1000: data_mem[ s_index ][ s_match ][ 287:256 ] <= i_data[ 31:0 ]; 
                        4'b1001: data_mem[ s_index ][ s_match ][ 319:288 ] <= i_data[ 31:0 ]; 
                        4'b1010: data_mem[ s_index ][ s_match ][ 351:320 ] <= i_data[ 31:0 ]; 
                        4'b1011: data_mem[ s_index ][ s_match ][ 383:352 ] <= i_data[ 31:0 ]; 
                        4'b1100: data_mem[ s_index ][ s_match ][ 415:384 ] <= i_data[ 31:0 ]; 
                        4'b1101: data_mem[ s_index ][ s_match ][ 447:416 ] <= i_data[ 31:0 ];
                        4'b1110: data_mem[ s_index ][ s_match ][ 479:448 ] <= i_data[ 31:0 ];
                        4'b1111: data_mem[ s_index ][ s_match ][ 511:480 ] <= i_data[ 31:0 ];
                        default: data_mem[ s_index ][ s_match ][ 31:0    ] <= '0;
                    endcase    
                end 

                // SH Instruction.
                2'b01: begin
                    case ( {s_word_offset, s_byte_offset[1]} )
                        5'b00000: data_mem[ s_index ][ s_match ][ 15 :0   ] <= i_data[ 15:0 ]; 
                        5'b00001: data_mem[ s_index ][ s_match ][ 31 :16  ] <= i_data[ 15:0 ]; 
                        5'b00010: data_mem[ s_index ][ s_match ][ 47 :32  ] <= i_data[ 15:0 ]; 
                        5'b00011: data_mem[ s_index ][ s_match ][ 63 :48  ] <= i_data[ 15:0 ]; 
                        5'b00100: data_mem[ s_index ][ s_match ][ 79 :64  ] <= i_data[ 15:0 ]; 
                        5'b00101: data_mem[ s_index ][ s_match ][ 95 :80  ] <= i_data[ 15:0 ]; 
                        5'b00110: data_mem[ s_index ][ s_match ][ 111:96  ] <= i_data[ 15:0 ]; 
                        5'b00111: data_mem[ s_index ][ s_match ][ 127:112 ] <= i_data[ 15:0 ]; 
                        5'b01000: data_mem[ s_index ][ s_match ][ 143:128 ] <= i_data[ 15:0 ]; 
                        5'b01001: data_mem[ s_index ][ s_match ][ 159:144 ] <= i_data[ 15:0 ]; 
                        5'b01010: data_mem[ s_index ][ s_match ][ 175:160 ] <= i_data[ 15:0 ]; 
                        5'b01011: data_mem[ s_index ][ s_match ][ 191:176 ] <= i_data[ 15:0 ]; 
                        5'b01100: data_mem[ s_index ][ s_match ][ 207:192 ] <= i_data[ 15:0 ]; 
                        5'b01101: data_mem[ s_index ][ s_match ][ 223:208 ] <= i_data[ 15:0 ]; 
                        5'b01110: data_mem[ s_index ][ s_match ][ 239:224 ] <= i_data[ 15:0 ];
                        5'b01111: data_mem[ s_index ][ s_match ][ 255:240 ] <= i_data[ 15:0 ]; 
                        5'b10000: data_mem[ s_index ][ s_match ][ 271:256 ] <= i_data[ 15:0 ]; 
                        5'b10001: data_mem[ s_index ][ s_match ][ 287:272 ] <= i_data[ 15:0 ]; 
                        5'b10010: data_mem[ s_index ][ s_match ][ 303:288 ] <= i_data[ 15:0 ]; 
                        5'b10011: data_mem[ s_index ][ s_match ][ 319:304 ] <= i_data[ 15:0 ]; 
                        5'b10100: data_mem[ s_index ][ s_match ][ 335:320 ] <= i_data[ 15:0 ]; 
                        5'b10101: data_mem[ s_index ][ s_match ][ 351:336 ] <= i_data[ 15:0 ]; 
                        5'b10110: data_mem[ s_index ][ s_match ][ 367:352 ] <= i_data[ 15:0 ]; 
                        5'b10111: data_mem[ s_index ][ s_match ][ 383:368 ] <= i_data[ 15:0 ]; 
                        5'b11000: data_mem[ s_index ][ s_match ][ 399:384 ] <= i_data[ 15:0 ]; 
                        5'b11001: data_mem[ s_index ][ s_match ][ 415:400 ] <= i_data[ 15:0 ]; 
                        5'b11010: data_mem[ s_index ][ s_match ][ 431:416 ] <= i_data[ 15:0 ];
                        5'b11011: data_mem[ s_index ][ s_match ][ 447:432 ] <= i_data[ 15:0 ];
                        5'b11100: data_mem[ s_index ][ s_match ][ 463:448 ] <= i_data[ 15:0 ];
                        5'b11101: data_mem[ s_index ][ s_match ][ 479:464 ] <= i_data[ 15:0 ];
                        5'b11110: data_mem[ s_index ][ s_match ][ 495:480 ] <= i_data[ 15:0 ];
                        5'b11111: data_mem[ s_index ][ s_match ][ 511:496 ] <= i_data[ 15:0 ];
                        default:  data_mem[ s_index ][ s_match ][ 31:0    ] <= '0;
                    endcase
                end

                // SB Instruction.
                2'b00: begin
                    case ( {s_word_offset, s_byte_offset} )
                        6'b000000: data_mem[ s_index ][ s_match ][ 7  :0   ] <= i_data[ 7:0 ]; 
                        6'b000001: data_mem[ s_index ][ s_match ][ 15 :8   ] <= i_data[ 7:0 ]; 
                        6'b000010: data_mem[ s_index ][ s_match ][ 23 :16  ] <= i_data[ 7:0 ]; 
                        6'b000011: data_mem[ s_index ][ s_match ][ 31 :24  ] <= i_data[ 7:0 ];

                        6'b000100: data_mem[ s_index ][ s_match ][ 39 :32  ] <= i_data[ 7:0 ]; 
                        6'b000101: data_mem[ s_index ][ s_match ][ 47 :40  ] <= i_data[ 7:0 ]; 
                        6'b000110: data_mem[ s_index ][ s_match ][ 55 :48  ] <= i_data[ 7:0 ]; 
                        6'b000111: data_mem[ s_index ][ s_match ][ 63 :56  ] <= i_data[ 7:0 ]; 

                        6'b001000: data_mem[ s_index ][ s_match ][ 71 :64  ] <= i_data[ 7:0 ]; 
                        6'b001001: data_mem[ s_index ][ s_match ][ 79 :72  ] <= i_data[ 7:0 ]; 
                        6'b001010: data_mem[ s_index ][ s_match ][ 87 :80  ] <= i_data[ 7:0 ]; 
                        6'b001011: data_mem[ s_index ][ s_match ][ 95 :88  ] <= i_data[ 7:0 ]; 

                        6'b001100: data_mem[ s_index ][ s_match ][ 103:96  ] <= i_data[ 7:0 ]; 
                        6'b001101: data_mem[ s_index ][ s_match ][ 111:104 ] <= i_data[ 7:0 ]; 
                        6'b001110: data_mem[ s_index ][ s_match ][ 119:112 ] <= i_data[ 7:0 ]; 
                        6'b001111: data_mem[ s_index ][ s_match ][ 127:120 ] <= i_data[ 7:0 ]; 

                        6'b010000: data_mem[ s_index ][ s_match ][ 135:128 ] <= i_data[ 7:0 ]; 
                        6'b010001: data_mem[ s_index ][ s_match ][ 143:136 ] <= i_data[ 7:0 ]; 
                        6'b010010: data_mem[ s_index ][ s_match ][ 151:144 ] <= i_data[ 7:0 ]; 
                        6'b010011: data_mem[ s_index ][ s_match ][ 159:152 ] <= i_data[ 7:0 ];

                        6'b010100: data_mem[ s_index ][ s_match ][ 167:160 ] <= i_data[ 7:0 ]; 
                        6'b010101: data_mem[ s_index ][ s_match ][ 175:168 ] <= i_data[ 7:0 ]; 
                        6'b010110: data_mem[ s_index ][ s_match ][ 183:176 ] <= i_data[ 7:0 ]; 
                        6'b010111: data_mem[ s_index ][ s_match ][ 191:184 ] <= i_data[ 7:0 ];

                        6'b011000: data_mem[ s_index ][ s_match ][ 199:192 ] <= i_data[ 7:0 ]; 
                        6'b011001: data_mem[ s_index ][ s_match ][ 207:200 ] <= i_data[ 7:0 ]; 
                        6'b011010: data_mem[ s_index ][ s_match ][ 215:208 ] <= i_data[ 7:0 ]; 
                        6'b011011: data_mem[ s_index ][ s_match ][ 223:216 ] <= i_data[ 7:0 ];

                        6'b011100: data_mem[ s_index ][ s_match ][ 231:224 ] <= i_data[ 7:0 ];
                        6'b011101: data_mem[ s_index ][ s_match ][ 239:232 ] <= i_data[ 7:0 ]; 
                        6'b011110: data_mem[ s_index ][ s_match ][ 247:240 ] <= i_data[ 7:0 ]; 
                        6'b011111: data_mem[ s_index ][ s_match ][ 255:248 ] <= i_data[ 7:0 ];

                        6'b100000: data_mem[ s_index ][ s_match ][ 263:256 ] <= i_data[ 7:0 ]; 
                        6'b100001: data_mem[ s_index ][ s_match ][ 271:264 ] <= i_data[ 7:0 ]; 
                        6'b100010: data_mem[ s_index ][ s_match ][ 279:272 ] <= i_data[ 7:0 ]; 
                        6'b100011: data_mem[ s_index ][ s_match ][ 287:280 ] <= i_data[ 7:0 ];

                        6'b100100: data_mem[ s_index ][ s_match ][ 295:288 ] <= i_data[ 7:0 ];  
                        6'b100101: data_mem[ s_index ][ s_match ][ 303:296 ] <= i_data[ 7:0 ]; 
                        6'b100110: data_mem[ s_index ][ s_match ][ 311:304 ] <= i_data[ 7:0 ]; 
                        6'b100111: data_mem[ s_index ][ s_match ][ 319:312 ] <= i_data[ 7:0 ]; 

                        6'b101000: data_mem[ s_index ][ s_match ][ 327:320 ] <= i_data[ 7:0 ]; 
                        6'b101001: data_mem[ s_index ][ s_match ][ 335:328 ] <= i_data[ 7:0 ]; 
                        6'b101010: data_mem[ s_index ][ s_match ][ 343:336 ] <= i_data[ 7:0 ]; 
                        6'b101011: data_mem[ s_index ][ s_match ][ 351:344 ] <= i_data[ 7:0 ]; 

                        6'b101100: data_mem[ s_index ][ s_match ][ 359:352 ] <= i_data[ 7:0 ]; 
                        6'b101101: data_mem[ s_index ][ s_match ][ 367:360 ] <= i_data[ 7:0 ]; 
                        6'b101110: data_mem[ s_index ][ s_match ][ 375:368 ] <= i_data[ 7:0 ]; 
                        6'b101111: data_mem[ s_index ][ s_match ][ 383:376 ] <= i_data[ 7:0 ];

                        6'b110000: data_mem[ s_index ][ s_match ][ 391:384 ] <= i_data[ 7:0 ];
                        6'b110001: data_mem[ s_index ][ s_match ][ 399:392 ] <= i_data[ 7:0 ];
                        6'b110010: data_mem[ s_index ][ s_match ][ 407:400 ] <= i_data[ 7:0 ]; 
                        6'b110011: data_mem[ s_index ][ s_match ][ 415:408 ] <= i_data[ 7:0 ];

                        6'b110100: data_mem[ s_index ][ s_match ][ 423:416 ] <= i_data[ 7:0 ]; 
                        6'b110101: data_mem[ s_index ][ s_match ][ 431:424 ] <= i_data[ 7:0 ];
                        6'b110110: data_mem[ s_index ][ s_match ][ 439:432 ] <= i_data[ 7:0 ]; 
                        6'b110111: data_mem[ s_index ][ s_match ][ 447:440 ] <= i_data[ 7:0 ];

                        6'b111000: data_mem[ s_index ][ s_match ][ 455:448 ] <= i_data[ 7:0 ]; 
                        6'b111001: data_mem[ s_index ][ s_match ][ 463:456 ] <= i_data[ 7:0 ]; 
                        6'b111010: data_mem[ s_index ][ s_match ][ 471:464 ] <= i_data[ 7:0 ]; 
                        6'b111011: data_mem[ s_index ][ s_match ][ 479:472 ] <= i_data[ 7:0 ]; 

                        6'b111100: data_mem[ s_index ][ s_match ][ 487:480 ] <= i_data[ 7:0 ]; 
                        6'b111101: data_mem[ s_index ][ s_match ][ 495:488 ] <= i_data[ 7:0 ]; 
                        6'b111110: data_mem[ s_index ][ s_match ][ 503:496 ] <= i_data[ 7:0 ]; 
                        6'b111111: data_mem[ s_index ][ s_match ][ 511:504 ] <= i_data[ 7:0 ]; 

                    endcase
                end
            endcase

        end
        else if ( block_write_en ) begin
            data_mem[ s_index ][ s_lru ] <= i_data_block;
            tag_mem [ s_index ][ s_lru ] <= s_tag_in; 
        end
    end

    // Modify dirty bit. 
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            // For 2-way set associative cache.
            dirty_mem [ 0 ] <= '0;
            dirty_mem [ 1 ] <= '0;
        end
        else if ( write_en       ) dirty_mem[ s_match    ][ s_index    ] <= 1'b1;
        else if ( block_write_en ) dirty_mem[ s_lru      ][ s_index    ] <= 1'b0;
        else if ( i_done_wb      ) dirty_mem[ s_count[1] ][ s_count[0] ] <= 1'b0;
    end

    // Write valid bit. 
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            // For 2-way set associative cache.
            valid_mem [ 0 ] <= '0;
            valid_mem [ 1 ] <= '0;
        end
        else if ( valid_update ) begin
            valid_mem[ s_lru ][ s_index ] <= 1'b1;
        end
    end

    // Write LRU set.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            lru_set <= '0;
        end
        else if ( lru_update ) begin
            lru_set[ s_index ] <= 1'b1;
        end
    end

    // Write LRU.
    integer j;
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            lru_mem [ 0 ][ 0 ] <= 1'b0;
            lru_mem [ 1 ][ 0 ] <= 1'b1;
            lru_mem [ 0 ][ 1 ] <= 1'b0;
            lru_mem [ 1 ][ 1 ] <= 1'b1;
        end
        else if ( lru_update ) begin
                lru_mem[ s_match ][ s_index ] <= 1'b1;
                for ( j = 0; j < N; j++ ) begin
                    if ( lru_mem[ j ][ s_index ] > lru_mem[ s_match ][ s_index ] ) begin
                        lru_mem[ j ][ s_index ] <= lru_mem[ j ][ s_index ] - 1'b1;
                    end
                end
        end
        else if ( ~ lru_set[ s_index ] ) begin
            // For 4-way set associative cache.
            lru_mem [ 0 ][ s_index ] <= 1'b0;
            lru_mem [ 1 ][ s_index ] <= 1'b1;
        end
    end



    //------------------------
    // Read logic.
    //------------------------

    // Read word.
    always_comb begin
        case ( s_word_offset )
            4'b0000: o_data = data_mem[ s_index ][ s_match ][ 63 :0   ]; 
            4'b0001: o_data = data_mem[ s_index ][ s_match ][ 95 :32  ]; 
            4'b0010: o_data = data_mem[ s_index ][ s_match ][ 127:64  ]; 
            4'b0011: o_data = data_mem[ s_index ][ s_match ][ 159:96  ]; 
            4'b0100: o_data = data_mem[ s_index ][ s_match ][ 191:128 ]; 
            4'b0101: o_data = data_mem[ s_index ][ s_match ][ 223:160 ]; 
            4'b0110: o_data = data_mem[ s_index ][ s_match ][ 255:192 ]; 
            4'b0111: o_data = data_mem[ s_index ][ s_match ][ 287:224 ]; 
            4'b1000: o_data = data_mem[ s_index ][ s_match ][ 319:256 ]; 
            4'b1001: o_data = data_mem[ s_index ][ s_match ][ 351:288 ]; 
            4'b1010: o_data = data_mem[ s_index ][ s_match ][ 383:320 ]; 
            4'b1011: o_data = data_mem[ s_index ][ s_match ][ 415:352 ]; 
            4'b1100: o_data = data_mem[ s_index ][ s_match ][ 447:384 ]; 
            4'b1101: o_data = data_mem[ s_index ][ s_match ][ 479:416 ];
            4'b1110: o_data = data_mem[ s_index ][ s_match ][ 511:448 ];
            4'b1111: o_data = { 32'b0, data_mem[ s_index ][ s_match ][ 511:480 ]};
            default: o_data = '0;
        endcase
    end

    //Read dirty bit.
    assign o_dirty      = i_start_wb ? dirty_mem[ s_count[1] ][ s_count[0] ] : dirty_mem[ s_lru ][ s_index ];
    assign o_data_block = i_start_wb ? data_mem[ s_count[0] ][ s_count[1] ]  : data_mem[ s_index ][ s_lru ];
    assign s_addr_wb    = { tag_mem[ s_index ][ s_lru ][ OUT_ADDR_WIDTH - 8:0 ], s_index, 6'b0 };
    assign s_addr       = { i_data_addr[ OUT_ADDR_WIDTH - 1:INDEX_LSB ], 6'b0 };
    assign s_addr_axi   = i_addr_control ? s_addr : s_addr_wb;
    assign o_addr_axi   = i_start_wb ? { tag_mem[ s_count[0] ][ s_count[1] ][ OUT_ADDR_WIDTH - 8:0 ], s_count[0] , 6'b0 } : s_addr_axi;

    logic [ 1:0 ] s_count;

    always_ff @( posedge clk, posedge arst ) begin
        if      ( arst      ) s_count <= '0;
        else if ( i_done_wb ) s_count <= s_count + 2'b1;
    end

    assign o_done_fence = i_done_wb & ( s_count == 2'b11 );
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------
// This is a data cache FSM for N-way set associative cache.
// -----------------------------------------------------------------------

module ysyx_201979054_data_cache_fsm 
#(
    parameter N = 4
)
(
    // Clock & Reset.
    input  logic clk,
    input  logic arst,

    // Input Interface.
    input  logic i_start_check,
    input  logic i_start_wb,
    input  logic i_hit,
    input  logic i_dirty,
    input  logic i_r_last,
    input  logic i_b_resp,

    // Output Interface.
    output logic o_stall,
    output logic o_data_block_write_en,
    output logic o_valid_update,
    output logic o_lru_update,
    output logic o_start_write,
    output logic o_start_read,
    output logic o_addr_control,
    output logic o_done_wb
);

    //------------------------------
    // FSM.
    //------------------------------

    // FSM: States.
    typedef enum logic [2:0 ] {
        IDLE        = 3'b000,
        COMPARE_TAG = 3'b001,
        ALLOCATE    = 3'b010,
        WRITE_BACK  = 3'b011,
        CHECK_DIRTY = 3'b100
    } t_state;

    t_state PS;
    t_state NS;

    // FSM: PS Syncronization.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            PS <= IDLE;
        end
        else PS <= NS;
    end

    // FSM: NS Logic.
    always_comb begin
        NS = PS;

        case ( PS )
            IDLE: if ( i_start_check ) NS = COMPARE_TAG;
             else if ( i_start_wb    ) NS = CHECK_DIRTY;

            COMPARE_TAG: begin
                if ( i_hit ) begin
                    NS = IDLE;
                end
                else if ( i_dirty ) begin
                    NS = WRITE_BACK;
                end
                else NS = ALLOCATE;
            end

            ALLOCATE: begin
                if ( i_r_last ) begin
                    NS = COMPARE_TAG;
                end
            end

            WRITE_BACK: begin
                if ( i_b_resp ) begin
                    if ( i_start_wb ) NS = IDLE;
                    else              NS = ALLOCATE;
                end
            end

            CHECK_DIRTY: begin
                if ( i_dirty ) NS = WRITE_BACK;
                else           NS = IDLE;
            end

            default: NS = PS;
        endcase
    end

    // FSM: Output Logic.
    always_comb begin
        o_stall               = 1'b1;
        o_data_block_write_en = 1'b0;
        o_valid_update        = 1'b0;
        o_lru_update          = 1'b0;
        o_start_write         = 1'b0;
        o_start_read          = 1'b0;
        o_addr_control        = 1'b1;
        o_done_wb             = 1'b0;

        case ( PS )
            IDLE: begin
                o_stall = 1'b1;
            end 

            COMPARE_TAG: begin
                o_stall          = ~i_hit;
                if      ( i_hit   ) o_lru_update   = 1'b1;
                else if ( i_dirty ) o_addr_control = 1'b0; 
            end

            ALLOCATE: begin
                o_start_read     = 1'b1;
                if ( i_r_last ) begin
                    o_data_block_write_en = 1'b1;
                    o_valid_update        = 1'b1;
                end
                else o_data_block_write_en = 1'b0;
            end

            WRITE_BACK: begin
                o_start_write  = 1'b1;
                o_done_wb      = i_b_resp & i_start_wb;
                if ( i_b_resp ) o_addr_control = 1'b1;
                else            o_addr_control = 1'b0;
            end

            CHECK_DIRTY: begin
                o_done_wb = ~i_dirty;
            end

            default: begin
                o_stall               = 1'b1;
                o_data_block_write_en = 1'b0;
                o_valid_update        = 1'b0;
                o_lru_update          = 1'b0;
                o_start_write         = 1'b0;
                o_start_read          = 1'b0;
                o_addr_control        = 1'b1;
            end
        endcase
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------
// This is a module to extend immediate input depending on type of instruction.
// ----------------------------------------------------------------------------

module ysyx_201979054_extend_imm
// Parameters.
#(
    parameter IMM_WIDTH = 25,
              OUT_WIDTH = 64
) 
// Port decleration.
(
    // Control signal. 
    input  logic [             2:0 ] control_signal,

    // Input interface.
    input  logic [ IMM_WIDTH - 1:0 ] i_imm,
    
    // Output interface.
    output logic [ OUT_WIDTH - 1:0 ] o_imm_ext
);

    logic [ OUT_WIDTH - 1:0 ] s_i_type;
    logic [ OUT_WIDTH - 1:0 ] s_s_type;
    logic [ OUT_WIDTH - 1:0 ] s_b_type;
    logic [ OUT_WIDTH - 1:0 ] s_j_type;
    logic [ OUT_WIDTH - 1:0 ] s_u_type;
    logic [ OUT_WIDTH - 1:0 ] csr_type;

    // Sign extend immediate for different instruction types. 
    assign s_i_type = { {52{i_imm[24]}}, i_imm[24:13] };
    assign s_s_type = { {52{i_imm[24]}}, i_imm[24:18], i_imm[4:0] };
    assign s_b_type = { {52{i_imm[24]}}, i_imm[0] , i_imm[23:18], i_imm[4:1], 1'b0 };
    assign s_j_type = { {44{i_imm[24]}}, i_imm[12:5], i_imm[13], i_imm[23:14], 1'b0 };
    assign s_u_type = { {32{i_imm[24]}}, i_imm[24:5], {12{1'b0}} };
    assign csr_type = { 59'b0, i_imm[12:8] };

    // MUX to choose output based on instruction type.
    //  ___________________________________
    // | control signal | instuction type |
    // |________________|_________________|
    // | 000            | I type          |
    // | 001            | S type          |
    // | 010            | B type          |
    // | 011            | J type          |
    // | 100            | U type          |
    // | 101            | CSR             |
    // |__________________________________|
    always_comb begin
        case ( control_signal )
            3'b000: o_imm_ext = s_i_type;
            3'b001: o_imm_ext = s_s_type;
            3'b010: o_imm_ext = s_b_type;
            3'b011: o_imm_ext = s_j_type;
            3'b100: o_imm_ext = s_u_type;
            3'b101: o_imm_ext = csr_type;
            default: o_imm_ext = s_i_type;
        endcase
    end

    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------------------
// This is fifo module that is used to store and output data as a queue in caching system.
// ----------------------------------------------------------------------------------------

module ysyx_201979054_fifo 
#(
    parameter AXI_DATA_WIDTH = 32,
              FIFO_WIDTH     = 512
) 
(
    // Control signals.
    input  logic                          clk,
    input  logic                          arst,
    input  logic                          write_en,
    input  logic                          start_read,
    input  logic                          start_write,

    // Input interface.
    input  logic [ AXI_DATA_WIDTH - 1:0 ] i_data,
    input  logic [ FIFO_WIDTH     - 1:0 ] i_data_block,

    // Output logic.
    output logic [ AXI_DATA_WIDTH - 1:0 ] o_data,
    output logic [ FIFO_WIDTH     - 1:0 ] o_data_block
);

    always_ff @( posedge clk, posedge arst ) begin
        if      ( arst ) o_data_block <= '0;
        else if ( ( ~start_write ) & ( ~start_read ) ) o_data_block <= i_data_block;
        else if ( write_en ) o_data_block <= { i_data, o_data_block[ FIFO_WIDTH - 1:AXI_DATA_WIDTH ] }; 
    end

    assign o_data = o_data_block [ AXI_DATA_WIDTH - 1:0 ];
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------------
// This is a instruction cache for for direct mapped cache.
// -------------------------------------------------------------------

module ysyx_201979054_instr_cache 
#(
    parameter BLOCK_COUNT   = 4,
              WORD_SIZE     = 32,
              BLOCK_WIDTH   = 512,
              ADDR_WIDTH    = 64
) 
(
    // Control signals.
    input  logic                       clk,
    input  logic                       write_en,
    input  logic                       arst,
    
    // Input Interface.
    input  logic [ ADDR_WIDTH  - 1:0 ] i_instr_addr,
    input  logic [ BLOCK_WIDTH - 1:0 ] i_inst,
    input  logic                       i_invalidate_instr,

    // Output Interface.
    output logic [ WORD_SIZE   - 1:0 ] o_instr,
    output logic                       o_hit,
    output logic                       o_instr_addr_ma

);
    // Local Parameters.
    localparam WORD_COUNT     = BLOCK_WIDTH/WORD_SIZE; // 16 bits.

    localparam WORD_OFFSET_W  = $clog2( WORD_COUNT );  // 4 bit.
    localparam BLOCK_NUMBER_W = $clog2( BLOCK_COUNT ); // 2 bit.
    localparam BYTE_OFFSET_W  = $clog2( WORD_SIZE/8 ); // 2 bit.

    localparam TAG_MSB         = ADDR_WIDTH - 1;                                 // 63.
    localparam TAG_LSB         = BLOCK_NUMBER_W + WORD_OFFSET_W + BYTE_OFFSET_W; // 8.
    localparam TAG_WIDTH       = TAG_MSB - TAG_LSB + 1;                          // 56
    localparam INDEX_MSB       = TAG_LSB - 1;                                    // 7.
    localparam INDEX_LSB       = WORD_OFFSET_W + BYTE_OFFSET_W;                  // 6.
    localparam WORD_OFFSET_MSB = INDEX_LSB - 1;                                  // 5.
    localparam WORD_OFFSET_LSB = BYTE_OFFSET_W;                                  // 2.

    // Internal signals.
    logic [ TAG_MSB         - TAG_LSB        :0 ] s_tag_in;
    logic [ INDEX_MSB       - INDEX_LSB      :0 ] s_index;
    logic [ WORD_OFFSET_MSB - WORD_OFFSET_LSB:0 ] s_word_offset;

    logic [ TAG_MSB         - TAG_LSB        :0 ] s_tag;

    logic s_tag_match;
    logic s_valid;


    // Continious assignments.
    assign s_tag_in      = i_instr_addr[ TAG_MSB        :TAG_LSB         ];
    assign s_index       = i_instr_addr[ INDEX_MSB      :INDEX_LSB       ]; 
    assign s_word_offset = i_instr_addr[ WORD_OFFSET_MSB:WORD_OFFSET_LSB ];

    // Instruction address misaligned exception.
    assign o_instr_addr_ma = | i_instr_addr[ 1:0 ];

    // Tag memory.
    logic [ TAG_WIDTH - 1:0 ] tag_mem [ BLOCK_COUNT - 1:0 ];

    // Valid memory.
    logic [ BLOCK_COUNT - 1:0 ] valid_mem;

    // Instruction memory.
    logic [ BLOCK_WIDTH - 1:0 ] instr_mem [ BLOCK_COUNT - 1:0 ];

    // Valid write logic.
    always_ff @( posedge clk, posedge arst, posedge i_invalidate_instr ) begin
        if ( arst | i_invalidate_instr ) begin
            valid_mem <= '0;
        end
        else if ( write_en ) begin
            valid_mem[ s_index ] <= 1'b1;
        end
    end

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            tag_mem [ 0 ] <= '0;
            tag_mem [ 1 ] <= '0;
            tag_mem [ 2 ] <= '0;
            tag_mem [ 3 ] <= '0;
            instr_mem     [ 0 ] <= '0;
            instr_mem     [ 1 ] <= '0;
            instr_mem     [ 2 ] <= '0;
            instr_mem     [ 3 ] <= '0;
        end
        else if ( write_en ) begin
            tag_mem  [ s_index ] <= s_tag_in;
            instr_mem      [ s_index ] <= i_inst;
        end
    end

    assign s_tag   = tag_mem  [ s_index ];
    assign s_valid = valid_mem[ s_index ];

    always_comb begin
        case ( s_word_offset )
            4'b0000: o_instr = instr_mem[ s_index ][ 31 :0   ]; 
            4'b0001: o_instr = instr_mem[ s_index ][ 63 :32  ]; 
            4'b0010: o_instr = instr_mem[ s_index ][ 95 :64  ]; 
            4'b0011: o_instr = instr_mem[ s_index ][ 127:96  ]; 
            4'b0100: o_instr = instr_mem[ s_index ][ 159:128 ]; 
            4'b0101: o_instr = instr_mem[ s_index ][ 191:160 ]; 
            4'b0110: o_instr = instr_mem[ s_index ][ 223:192 ]; 
            4'b0111: o_instr = instr_mem[ s_index ][ 255:224 ]; 
            4'b1000: o_instr = instr_mem[ s_index ][ 287:256 ]; 
            4'b1001: o_instr = instr_mem[ s_index ][ 319:288 ]; 
            4'b1010: o_instr = instr_mem[ s_index ][ 351:320 ]; 
            4'b1011: o_instr = instr_mem[ s_index ][ 383:352 ]; 
            4'b1100: o_instr = instr_mem[ s_index ][ 415:384 ]; 
            4'b1101: o_instr = instr_mem[ s_index ][ 447:416 ];
            4'b1110: o_instr = instr_mem[ s_index ][ 479:448 ];
            4'b1111: o_instr = instr_mem[ s_index ][ 511:480 ];
            default: o_instr = '0;
        endcase
    end

    assign s_tag_match = (s_tag == s_tag_in);
    assign o_hit       = s_valid & s_tag_match;
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------
// This is a instruction cache FSM for direct mapped cache.
// -----------------------------------------------------------------------

module ysyx_201979054_instr_cache_fsm 
(
    // Clock & Reset.
    input  logic clk,
    input  logic arst,

    // Input Interface.
    input  logic i_start_check,
    input  logic i_hit,
    input  logic i_r_last,

    // Output Interface.
    output logic o_stall,
    output logic o_instr_write_en,
    output logic o_start_read,
    output logic o_in_idle
);

    //------------------------------
    // FSM.
    //------------------------------

    // FSM: States.
    typedef enum logic [1:0 ] {
        IDLE        = 2'b00,
        COMPARE_TAG = 2'b01,
        ALLOCATE    = 2'b10
    } t_state;

    t_state PS;
    t_state NS;

    // FSM: PS Syncronization.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            PS <= IDLE;
        end
        else PS <= NS;
    end

    // FSM: NS Logic.
    always_comb begin
        NS = PS;

        case ( PS )
            IDLE: if ( i_start_check ) begin
                NS = COMPARE_TAG;
            end

            COMPARE_TAG: begin
                if ( i_hit ) begin
                    NS = IDLE;
                end
                else NS = ALLOCATE;
            end

            ALLOCATE: begin
                if ( i_r_last ) begin
                    NS = COMPARE_TAG;
                end
            end
            default: NS = PS;
        endcase
    end

    // FSM: Output Logic.
    always_comb begin

        // Default values.
        o_stall          = 1'b0;
        o_start_read     = 1'b0;
        o_instr_write_en = 1'b0;
        
        case ( PS )
            IDLE: begin
                o_stall          = 1'b1;
                o_start_read     = 1'b0;
                o_instr_write_en = 1'b0;
            end 

            COMPARE_TAG: begin
                o_stall          = ~i_hit;
                o_start_read     = 1'b0;
                o_instr_write_en = 1'b0;
            end

            ALLOCATE: begin
                o_stall          = 1'b1;
                o_start_read     = 1'b1;
                if ( i_r_last ) begin
                    o_instr_write_en = 1'b1;
                end
                else o_instr_write_en = 1'b0;
            end
            default: begin
                o_stall          = 1'b0;
                o_start_read     = 1'b0;
                o_instr_write_en = 1'b0;
            end
        endcase
    end

    assign o_in_idle = ( PS == IDLE ); 
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------
// This is a module designed to assign ImmSrc based on instruction opcode.
// ImmSrc is a signal designed to control immediate extension logic.
// -----------------------------------------------------------------------

module ysyx_201979054_instr_decoder 
// Parameters.
#(
    parameter OP_WIDTH  = 7,
              OUT_WIDTH = 3
)
// Ports. 
(
    input  logic [ OP_WIDTH  - 1:0 ] i_op,
    output logic [ OUT_WIDTH - 1:0 ] o_imm_src
); 

    //Decoder logic.
    /*
    __________________
    | OP      | Type |
    |---------|------|
    | 0000011 | I    |
    | 0010011 | I    |
    | 1100111 | I    |
    | 0100011 | S    |
    | 1100011 | B    |
    | 1101111 | J    |
    |________________|

     ___________________________________
    | control signal | instuction type |
    |________________|_________________|
    | 000            | I type          |
    | 001            | S type          |
    | 010            | B type          |
    | 011            | J type          |
    | 100            | U type          |
    |__________________________________|
    */

    always_comb begin
        case ( i_op )
            7'b1101111: o_imm_src = 3'b011; // J type.
            7'b1100011: o_imm_src = 3'b010; // B type.
            7'b0100011: o_imm_src = 3'b001; // S type.
            7'b0010111: o_imm_src = 3'b100; // U type.
            7'b0110111: o_imm_src = 3'b100; // U type. 
            7'b0000011: o_imm_src = 3'b000; // I type.
            7'b0010011: o_imm_src = 3'b000; // I type.
            7'b1100111: o_imm_src = 3'b000; // I type.
            7'b0011011: o_imm_src = 3'b000; // I type.
            7'b1110011: o_imm_src = 3'b101; // CSR. 
            default:    o_imm_src = 3'b000; // Default = for I type.
        endcase
    end

endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------
// This is a module designed to take 64-bit data from memory & adjust it 
// based on different LOAD instruction requirements. 
// -----------------------------------------------------------------------

module ysyx_201979054_load_mux 
#(
    parameter DATA_WIDTH = 64
) 
(
    // Control logic.
    input  logic [              2:0 ] i_func_3,

    // Input interface. 
    input  logic [ DATA_WIDTH - 1:0 ] i_data,
    input  logic [              2:0 ] i_addr_offset,

    // Output interface
    output logic [ DATA_WIDTH - 1:0 ] o_data,
    output logic                      o_load_addr_ma,
    output logic                      o_illegal_instr
);

    logic [7:0]  s_byte;
    logic [15:0] s_half;

    logic s_load_addr_ma_lh;
    logic s_load_addr_ma_lw;
    logic s_load_addr_ma_ld;

    assign s_load_addr_ma_lh = i_addr_offset[0];
    assign s_load_addr_ma_lw = | i_addr_offset[1:0];
    assign s_load_addr_ma_ld = | i_addr_offset;

    always_comb begin
        case ( i_addr_offset[1:0] )
            2'b00: s_byte = i_data[ 7:0 ];
            2'b01: s_byte = i_data[15:8 ];
            2'b10: s_byte = i_data[23:16];
            2'b11: s_byte = i_data[31:24];
            default: s_byte = i_data[ 7:0 ];
        endcase 
    end

    assign s_half = i_addr_offset[1] ? i_data[31:16] : i_data[15:0];


    always_comb begin
        o_illegal_instr = 1'b0;

        case ( i_func_3 )
            3'b000: begin
                o_data          = { { 56{s_byte[7]} }, s_byte};        // LB  Instruction. 
                o_load_addr_ma  = 1'b0;               
            end 

            3'b001: begin
               o_data          = { { 48{s_half[15]} }, s_half};        // LH  Instruction.
               o_load_addr_ma  = s_load_addr_ma_lh;
            end

            3'b010: begin 
                o_data          = { { 32{i_data[31]} }, i_data[31:0]}; // LW  Instruction.
                o_load_addr_ma  = s_load_addr_ma_lw;
            end

            3'b011: begin 
                o_data          = i_data;                              // LD  Instruction.
                o_load_addr_ma  = s_load_addr_ma_ld;
            end

            3'b100: begin
                o_data          = { { 56{1'b0} }, s_byte};            // LBU Instruction. 
                o_load_addr_ma  = 1'b0;  
            end

            3'b101: begin 
                o_data          = { { 48{1'b0} }, s_half};             // LHU Instruction.
                o_load_addr_ma  = s_load_addr_ma_lh;
            end

            3'b110: begin 
                o_data          = { { 32{1'b0} }, i_data[31:0]};       // LWU Instruction.
                o_load_addr_ma  = s_load_addr_ma_lw;
            end
        
            default:  begin
                o_data          = '0;
                o_load_addr_ma  = 1'b0;
                o_illegal_instr = 1'b1;
            end

        endcase
    end
    
endmodule
/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -----------------------------------------------------------------------------------------
// This is a main fsm unit that controls all the control signals based on instruction input. 
// -----------------------------------------------------------------------------------------

module ysyx_201979054_main_fsm   
// Port decleration. 
(
    // Common clock & reset.
    input  logic       clk,
    input  logic       arst,

    // Input interface. 
    input  logic [ 2:0] i_instr_22_20,
    input  logic [ 6:0] i_op,
    input  logic [ 2:0] i_func_3,
    input  logic        i_func_7_4,
    input  logic        i_func_7_0, 
    input  logic        i_func_7_1,
    input  logic        i_func_7_6,
    input  logic        i_pred_0,
    input  logic        i_stall_instr,
    input  logic        i_stall_data,
    input  logic        i_instr_addr_ma,
    input  logic        i_store_addr_ma,
    input  logic        i_load_addr_ma,
    input  logic        i_illegal_instr_load,
    input  logic        i_illegal_instr_alu,
    input  logic        i_timer_int,
    input  logic        i_software_int, 
    input  logic        i_cacheable_flag,
    input  logic        i_done_axi,
    input  logic        i_clint_mmio_flag,
    input  logic        i_icache_idle,
    input  logic        i_done_fence,

    // Output interface.
    output logic [ 2:0] o_alu_op,
    output logic [ 2:0] o_result_src,
    output logic [ 1:0] o_alu_src_1,
    output logic [ 1:0] o_alu_src_2,
    output logic        o_reg_write_en,
    output logic        o_pc_update,
    output logic        o_mem_write_en,
    output logic        o_instr_write_en, 
    output logic        o_start_i_cache,
    output logic        o_start_d_cache, 
    output logic        o_branch,
    output logic        o_mem_reg_we,
    output logic        o_fetch_state,
    output logic        o_reg_mem_addr_we,
    output logic        o_start_read_nc,
    output logic        o_start_write_nc,
    output logic        o_invalidate_instr,
    output logic        o_write_en_clint,
    output logic        o_mret_instr,
    output logic        o_interrupt,
    output logic        o_start_wb,
    output logic        o_csr_writable,
    output logic [ 3:0] o_mcause,
    output logic        o_csr_we_1,
    output logic        o_csr_we_2,
    output logic        o_csr_reg_we,
    output logic [ 2:0] o_csr_write_addr_1,
    output logic [ 2:0] o_csr_write_addr_2,
    output logic [ 2:0] o_csr_read_addr
);  

    logic s_func_3_reduction;
    logic [2:0] s_csr_addr;
    logic [2:0] s_csr_addr_read_only;

    assign s_csr_addr = { i_func_7_1, i_instr_22_20[2], i_instr_22_20[0] };
    assign s_csr_addr_read_only = { 1'b0, i_instr_22_20 [ 1:0 ] };
    assign s_func_3_reduction = | i_func_3;

    // State type.
    typedef enum logic [3:0] {
        FETCH       = 4'b0000,
        DECODE      = 4'b0001,
        MEMADDR     = 4'b0010,
        MEMREAD     = 4'b0011,
        MEMWB       = 4'b0100,
        MEMWRITE    = 4'b0101,
        EXECUTER    = 4'b0110,
        ALUWB       = 4'b0111,
        EXECUTEI    = 4'b1000,
        JAL         = 4'b1001,
        BRANCH      = 4'b1010,
        LOADI       = 4'b1011,
        CALL_0      = 4'b1100,
        CSR_EXECUTE = 4'b1101,
        CSR_WB      = 4'b1110,
        FENCE_I     = 4'b1111
    } t_state;

    // State variables. 
    t_state PS;
    t_state NS;

    // Instruction type.
    typedef enum logic [3:0] {
        I_Type      = 4'b0000,
        I_Type_ALU  = 4'b0001,
        I_Type_JALR = 4'b0010,
        I_Type_IW   = 4'b0011,
        S_Type      = 4'b0100,
        R_Type      = 4'b0101,
        R_Type_W    = 4'b0110,
        B_Type      = 4'b0111,
        J_Type      = 4'b1000,
        U_Type_ALU  = 4'b1001,
        U_Type_LOAD = 4'b1010,
        FENCE_Type  = 4'b1011,
        CSR_Type    = 4'b1100,
        ILLEGAL     = 4'b1101
    } t_instruction;

    // Instruction decoder signal. 
    t_instruction instr;

    // Instruction decoder. 
    always_comb begin
        case ( i_op )
            7'b0000011: instr = I_Type;
            7'b0010011: instr = I_Type_ALU;
            7'b1100111: instr = I_Type_JALR;
            7'b0011011: instr = I_Type_IW;
            7'b0100011: instr = S_Type;
            7'b0110011: instr = R_Type;
            7'b0111011: instr = R_Type_W;
            7'b1100011: instr = B_Type;
            7'b1101111: instr = J_Type;
            7'b0010111: instr = U_Type_ALU;
            7'b0110111: instr = U_Type_LOAD; 
            7'b0001111: instr = FENCE_Type;
            7'b1110011: instr = CSR_Type;
            default:    instr = ILLEGAL;
        endcase
    end


    // -----------------------------------
    // FSM 
    // -----------------------------------
    // FSM: Synchronization.
    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) begin
            PS <= FETCH;
        end
        else PS <= NS;
    end

    // FSM: Next State logic.
    always_comb begin
        NS = PS;

        case ( PS )
            FETCH: begin
                if ( ( i_instr_addr_ma | i_timer_int | i_software_int ) & i_icache_idle ) NS = CALL_0;
                else if ( i_stall_instr            ) NS = PS;
                else                                 NS = DECODE;
            end 

            DECODE: begin
                case ( instr )
                    I_Type     : NS = MEMADDR;
                    I_Type_ALU : NS = EXECUTEI;
                    I_Type_JALR: NS = MEMADDR;
                    I_Type_IW  : NS = EXECUTEI; 
                    S_Type     : NS = MEMADDR;
                    R_Type     : NS = EXECUTER; 
                    R_Type_W   : NS = EXECUTER;
                    B_Type     : NS = BRANCH;
                    J_Type     : NS = JAL;
                    U_Type_ALU : NS = ALUWB;
                    U_Type_LOAD: NS = LOADI; 
                    FENCE_Type : NS = FENCE_I; // ONLY FENCE.I is IMPLEMENTED.
                    CSR_Type   : begin
                        if ( s_func_3_reduction ) NS = CSR_EXECUTE; // CSR.
                        else if ( i_func_7_4    ) NS = JAL;         // MRET. PROBLEM: NOT FINISHED.
                        else                      NS = CALL_0;      // Break                             
                    end 
                    ILLEGAL    : NS = CALL_0;
                    default:     NS = CALL_0; 
                endcase
            end

            MEMADDR: begin
                case ( instr )
                    I_Type     : NS = MEMREAD;
                    S_Type     : NS = MEMWRITE; 
                    I_Type_JALR: NS = JAL;
                    default: NS = PS;
                endcase
            end

            MEMREAD: begin
                if ( i_load_addr_ma | i_illegal_instr_load ) NS = CALL_0;
                else if ( ~ i_cacheable_flag ) begin
                    if ( i_done_axi | i_clint_mmio_flag )    NS = MEMWB;
                    else                                     NS = PS;
                end
                else if ( i_stall_data )                     NS = PS;
                else                                         NS = MEMWB;
            end

            MEMWB: NS = FETCH;

            MEMWRITE: begin
                if ( i_store_addr_ma )   NS = CALL_0;
                else if ( i_clint_mmio_flag  ) NS = FETCH;
                else if ( ~ i_cacheable_flag ) begin
                    if ( i_done_axi )    NS = FETCH;
                    else                 NS = PS;
                end
                else if ( i_stall_data ) NS = PS;
                else                     NS = FETCH;
            end

            EXECUTER: NS = ALUWB;

            ALUWB: begin
                if ( i_illegal_instr_alu | ( i_func_7_0 & i_op[5] & (~ i_op[6]) )) NS = CALL_0;
                else                       NS = FETCH;    
            end

            EXECUTEI: NS = ALUWB;

            JAL: begin
                if ( instr == CSR_Type ) NS = FETCH;
                else                     NS = ALUWB;          
            end 


            BRANCH: NS = FETCH;
            
            LOADI: NS = FETCH;

            CALL_0: NS = FETCH;

            CSR_EXECUTE: begin
                if ( i_illegal_instr_alu ) NS = CALL_0;
                else                       NS = CSR_WB;                 
            end 

            CSR_WB: NS = FETCH;

            FENCE_I: if      ( i_func_3[0]              ) NS = FETCH;
                     else if ( i_done_fence | !i_pred_0 ) NS = FETCH;

            default: NS = PS;
        endcase
    end


    // FSM: Ouput logic.
    always_comb begin

        // Default values. 
        o_alu_op           = 3'b000;
        o_result_src       = 3'b000;
        o_alu_src_1        = 2'b00;
        o_alu_src_2        = 2'b00;
        o_reg_write_en     = 1'b0;
        o_pc_update        = 1'b0;
        o_mem_write_en     = 1'b0;
        o_instr_write_en   = 1'b0;
        o_start_i_cache    = 1'b0;
        o_branch           = 1'b0;
        o_start_d_cache    = 1'b0;
        o_mem_reg_we       = 1'b0;
        o_fetch_state      = 1'b0;
        o_reg_mem_addr_we  = 1'b0;
        o_start_read_nc    = 1'b0;
        o_start_write_nc   = 1'b0;
        o_invalidate_instr = 1'b0;
        o_write_en_clint   = 1'b0;
        o_mret_instr       = 1'b0;
        o_interrupt        = 1'b0;
        o_start_wb         = 1'b0;
        o_csr_writable     = 1'b1;
        o_mcause           = 4'b0000;
        o_csr_we_1         = 1'b0;
        o_csr_we_2         = 1'b0;
        o_csr_reg_we       = 1'b0;
        o_csr_write_addr_1 = s_csr_addr;
        o_csr_write_addr_2 = s_csr_addr;
        o_csr_read_addr    = s_csr_addr;

        case ( PS )
            FETCH: begin
                o_result_src    = 3'b010; // Alu result
                o_start_i_cache = 1'b1;
                o_fetch_state   = 1'b1; 
                o_alu_src_1     = 2'b00;
                o_alu_src_2     = 2'b10;
                o_alu_op        = 3'b000;

                if ( i_instr_addr_ma ) begin
                    o_mcause           = 4'd0; // Instruction address misaligned.
                    o_interrupt        = 1'b0;
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                    o_start_i_cache    = 1'b0;
                end

                if ( ( i_software_int | i_timer_int ) & i_icache_idle ) begin
                    if ( i_timer_int ) o_mcause = 4'd7; // Machine timer interrupt.
                    else               o_mcause = 4'd3; // Machine software interrupt.
                    o_interrupt        = 1'b1;
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                    o_start_i_cache    = 1'b0;
                end

                if ( i_stall_instr ) begin
                    o_instr_write_en   = 1'b0;
                    o_pc_update        = 1'b0;
                end
                else begin
                    o_instr_write_en   = 1'b1;
                    o_pc_update        = 1'b1;      
                end
                
            end 

            DECODE: begin
                o_alu_src_1  = 2'b01;
                o_alu_src_2  = 2'b01;
                o_alu_op     = 3'b000;

                if ( (instr == CSR_Type) & ( ~s_func_3_reduction ) ) begin
                    if ( i_func_7_4 ) begin
                        o_mret_instr = 1'b1;
                    end
                    else begin
                        if ( ~i_instr_22_20[0] ) o_mcause = 4'd11; // Env call from M-mode.
                        else                     o_mcause = 4'd3; // Env breakpoint.
                        o_csr_write_addr_1 = 3'b100;  // mcause.
                        o_csr_we_1         = 1'b1; 
                        o_csr_write_addr_2 = 3'b101;  // mepc.
                        o_result_src       = 3'b110; // s_old_pc.  
                        o_csr_we_2         = 1'b1;   
                    end
                end
                if ( instr == ILLEGAL ) begin
                    o_mcause           = 4'd2; // Illegal instruction.
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                end
            end

            MEMADDR: begin
                o_alu_src_1    = 2'b10;
                o_alu_src_2    = 2'b01;
                o_alu_op       = 3'b000;
                o_result_src   = 3'b010;
                o_reg_mem_addr_we = 1'b1;
            end

            MEMREAD: begin
                o_result_src    = 3'b000;
                o_start_d_cache = 1'b1;
                o_alu_op        = 3'b000;
                o_alu_src_1     = 2'b10;
                o_alu_src_2     = 2'b01; 

                if ( ~ i_cacheable_flag ) begin
                    o_start_d_cache = 1'b0;
                    o_start_read_nc = ~ i_clint_mmio_flag;
                end

                if ( i_load_addr_ma ) begin
                    o_mcause           = 4'd4; // Load address misaligned.
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                    o_start_d_cache    = 1'b0;
                    o_start_read_nc    = 1'b0;
                end

                if ( i_illegal_instr_load ) begin
                    o_mcause           = 4'd2; // Illegal instruction.
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                    o_start_d_cache    = 1'b0;
                    o_start_read_nc    = 1'b0;
                end 

                if ( i_stall_data ) o_mem_reg_we = 1'b0;
                else                o_mem_reg_we = 1'b1;   
            end

            MEMWB: begin
                o_result_src   = 3'b001;
                o_reg_write_en = 1'b1;
            end

            MEMWRITE: begin
                o_result_src    = 3'b000;
                o_start_d_cache = 1'b1;
                o_alu_op        = 3'b000;
                o_alu_src_1     = 2'b10;
                o_alu_src_2     = 2'b01;

                if ( ~ i_cacheable_flag ) begin
                    o_start_d_cache  = 1'b0;
                    o_start_write_nc = 1'b1;
                end

                if ( i_clint_mmio_flag ) begin
                    o_start_d_cache  = 1'b0;
                    o_write_en_clint = 1'b1;
                    o_start_write_nc = 1'b0;
                end
                if ( i_store_addr_ma ) begin
                    o_mcause           = 4'd6; // Store address misaligned.
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                    o_start_d_cache    = 1'b0;
                    o_start_write_nc   = 1'b0;
                    o_write_en_clint   = 1'b0;
                end

                if ( i_stall_data ) begin
                    o_mem_write_en  = 1'b0;
                    o_mem_reg_we    = 1'b0;
                end
                else begin
                    o_mem_write_en  = 1'b1;
                    o_mem_reg_we    = 1'b1;      
                end
            end

            EXECUTER: begin
                o_alu_src_1 = 2'b10;
                o_alu_src_2 = 2'b00;
                case ( instr )
                    R_Type  : o_alu_op = 3'b010;
                    R_Type_W: o_alu_op = 3'b011;
                    default:  o_alu_op = 3'b010;
                endcase
            end

            ALUWB: begin
                o_result_src   = 3'b000;
                o_reg_write_en = 1'b1;
                
                if ( i_illegal_instr_alu | ( i_func_7_0 & i_op[5] & (~ i_op[6]) )) begin
                    o_mcause           = 4'd2; // Illegal instruction.
                    o_csr_write_addr_1 = 3'b100;  // mcause.
                    o_csr_we_1         = 1'b1; 
                    o_csr_write_addr_2 = 3'b101;  // mepc.
                    o_result_src       = 3'b110; // s_old_pc.  
                    o_csr_we_2         = 1'b1; 
                end
            end

            EXECUTEI: begin
                o_alu_src_1 = 2'b10;
                o_alu_src_2 = 2'b01;
                case ( instr )
                    I_Type_ALU: o_alu_op = 3'b010;
                    I_Type_IW : o_alu_op = 3'b011;
                    default:    o_alu_op = 3'b010;
                endcase
            end

            JAL: begin
                o_alu_src_1       = 2'b01;
                o_alu_src_2       = 2'b10;
                o_alu_op          = 3'b000;
                o_pc_update       = 1'b1;
                o_csr_read_addr   = 3'b101;  // mepc.
                
                if ( instr == CSR_Type ) o_result_src = 3'b100; // s_csr_data.
                else                     o_result_src = 3'b000;
            end

            BRANCH: begin
                o_alu_src_1  = 2'b10;
                o_alu_src_2  = 2'b00;
                o_alu_op     = 3'b001;
                o_result_src = 3'b000;
                o_branch     = 1'b1;
            end

            LOADI: begin
                o_result_src   = 3'b011;
                o_reg_write_en = 1'b1; 
            end

            CALL_0: begin
                o_csr_read_addr   = 3'b011;  // mtvec.
                o_pc_update       = 1'b1;
                o_result_src      = 3'b111; // s_csr_jump_addr.
            end

            CSR_EXECUTE: begin
                if ( i_func_3[2] ) o_alu_src_1  = 2'b11;
                else               o_alu_src_1  = 2'b10;
                o_alu_src_2    = 2'b11;
                o_alu_op       = 3'b100;
                o_csr_we_2     = 1'b1;
                o_result_src   = 3'b010;
                o_csr_reg_we   = 1'b1;
                o_csr_writable = 1'b1;
                if ( i_func_7_6 ) begin
                    o_csr_writable     = 1'b0;
                    o_csr_we_2         = 1'b0;  
                    o_csr_read_addr    = s_csr_addr_read_only; // Mvendorid, Marchid, Mimpid, Mhartid.
                end
                else begin 
                    o_csr_write_addr_2 = s_csr_addr;
                    o_csr_read_addr    = s_csr_addr;
                end
            end

            CSR_WB: begin
                o_reg_write_en    = 1'b1;
                o_result_src      = 3'b101; // s_csr_read_data_reg
                o_csr_writable    = ~i_func_7_6;
                if ( i_func_7_6 ) o_csr_read_addr = s_csr_addr_read_only;
                else              o_csr_read_addr = s_csr_addr;
            end

            FENCE_I: begin
                if ( i_func_3[0] ) begin
                    o_invalidate_instr = 1'b1;
                    o_start_wb         = 1'b0;
                end
                else if ( i_pred_0 ) begin
                    o_invalidate_instr = 1'b0;
                    o_start_wb         = 1'b1;
                end
                else begin
                    o_invalidate_instr = 1'b0;
                    o_start_wb         = 1'b0;
                end
            end


            default: begin
                o_alu_op           = 3'b000;
                o_result_src       = 3'b000;
                o_alu_src_1        = 2'b00;
                o_alu_src_2        = 2'b00;
                o_reg_write_en     = 1'b0;
                o_pc_update        = 1'b0;
                o_mem_write_en     = 1'b0;
                o_instr_write_en   = 1'b0;
                o_start_i_cache    = 1'b0;
                o_branch           = 1'b0;
                o_start_d_cache    = 1'b0;
                o_mem_reg_we       = 1'b0;
                o_fetch_state      = 1'b0;
                o_reg_mem_addr_we  = 1'b0;
                o_start_read_nc    = 1'b0;
                o_start_write_nc   = 1'b0;
                o_invalidate_instr = 1'b0;
                o_write_en_clint   = 1'b0;
                o_mret_instr       = 1'b0;
                o_interrupt        = 1'b0;
                o_start_wb         = 1'b0;
                o_csr_writable     = 1'b1;
                o_mcause           = 4'b0000;
                o_csr_we_1         = 1'b0;
                o_csr_we_2         = 1'b0;
                o_csr_reg_we       = 1'b0;
                o_csr_write_addr_1 = s_csr_addr;
                o_csr_write_addr_2 = s_csr_addr;
                o_csr_read_addr    = s_csr_addr;
            end
        endcase
    end
    
endmodule
/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ------------------------------------------------------
// This is a 2-to-1 mux module to choose Memory address.
// It can choose either PCNext or calculated result.
// ------------------------------------------------------

module ysyx_201979054_mux2to1
// Parameters. 
#(
    parameter ADDR_WIDTH = 64
) 
// Port decleration.
(
    // Control signal.
    input  logic                      control_signal,

    // Input interface.
    input  logic [ ADDR_WIDTH - 1:0 ] i_mux_0,
    input  logic [ ADDR_WIDTH - 1:0 ] i_mux_1,

    // Output interface.
    output logic [ ADDR_WIDTH - 1:0 ] o_mux
);

    // MUX logic.
    always_comb begin
        if ( control_signal ) begin
            o_mux = i_mux_1;
        end
        else o_mux = i_mux_0;
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// --------------------------------------------------
// This is a 4-to-1 mux module to choose Result Src.
// ---------------------------------------------------

module ysyx_201979054_mux4to1
// Parameters. 
#(
    parameter DATA_WIDTH = 64
) 
// Port decleration.
(
    // Control signal.
    input  logic [              1:0 ] control_signal,

    // Input interface.
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_0,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_1,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_2,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_3,

    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_mux
);

    // MUX logic.
    always_comb begin
        case ( control_signal )
            2'b00: o_mux = i_mux_0;
            2'b01: o_mux = i_mux_1;
            2'b10: o_mux = i_mux_2;
            2'b11: o_mux = i_mux_3;
            default: o_mux = '0;
        endcase
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// --------------------------------------------------
// This is a 8-to-1 mux module to choose Result Src.
// ---------------------------------------------------

module ysyx_201979054_mux8to1
// Parameters. 
#(
    parameter DATA_WIDTH = 64
) 
// Port decleration.
(
    // Control signal.
    input  logic [              2:0 ] control_signal,

    // Input interface.
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_0,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_1,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_2,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_3,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_4,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_5,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_6,
    input  logic [ DATA_WIDTH - 1:0 ] i_mux_7,

    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_mux
);

    // MUX logic.
    always_comb begin
        case ( control_signal )
            3'b000: o_mux = i_mux_0;
            3'b001: o_mux = i_mux_1;
            3'b010: o_mux = i_mux_2;
            3'b011: o_mux = i_mux_3;
            3'b100: o_mux = i_mux_4;
            3'b101: o_mux = i_mux_5;
            3'b110: o_mux = i_mux_6;
            3'b111: o_mux = i_mux_7;
            default: o_mux = '0;
        endcase
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------
// This is a nonarchitectural register without write enable signal.
// ----------------------------------------------------------------

module ysyx_201979054_register
// Parameters.
#(
    parameter DATA_WIDTH = 64
)
// Port decleration. 
(   
    // Common clock & enable signal.
    input  logic                      clk,
    input  logic                      arst,

    //Input interface. 
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data,
    
    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_read_data
);

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) o_read_data <= '0;
        else o_read_data <= i_write_data;
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// -------------------------------------------------------------
// This is a nonarchitectural register with write enable signal.
// -------------------------------------------------------------

module ysyx_201979054_register_en
// Parameters.
#(
    parameter DATA_WIDTH = 64
)
// Port decleration. 
(   
    // Common clock & enable signal.
    input  logic                      clk,
    input  logic                      write_en,
    input  logic                      arst,

    //Input interface. 
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data,
    
    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_read_data
);

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) o_read_data <= '0;
        else if ( write_en ) begin
            o_read_data <= i_write_data;
        end
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------
// This is a register file component of processor based on RISC-V architecture.
// ----------------------------------------------------------------------------

module ysyx_201979054_register_file
// Parameters.
#(
    parameter DATA_WIDTH = 64,
              ADDR_WIDTH = 5,
              REG_DEPTH  = 32
)
// Port decleration. 
(   
    // Common clock & enable signal.
    input  logic                      clk,
    input  logic                      write_en_3,
    input  logic                      arst,

    //Input interface. 
    input  logic [ ADDR_WIDTH - 1:0 ] i_addr_1,
    input  logic [ ADDR_WIDTH - 1:0 ] i_addr_2,
    input  logic [ ADDR_WIDTH - 1:0 ] i_addr_3,
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data_3,
    
    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_read_data_1,
    output logic [ DATA_WIDTH - 1:0 ] o_read_data_2
);

    // Register block.
    logic [ DATA_WIDTH - 1:0 ] mem [ REG_DEPTH - 1:0 ];

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) begin
            mem[0] <= '0;
            mem[1] <= '0;
            mem[2] <= '0;
            mem[3] <= '0;
            mem[4] <= '0;
            mem[5] <= '0;
            mem[6] <= '0;
            mem[7] <= '0;
            mem[8] <= '0;
            mem[9] <= '0;
            mem[10] <= '0;
            mem[11] <= '0;
            mem[12] <= '0;
            mem[13] <= '0;
            mem[14] <= '0;
            mem[15] <= '0;
            mem[16] <= '0;
            mem[17] <= '0;
            mem[18] <= '0;
            mem[19] <= '0;
            mem[20] <= '0;
            mem[21] <= '0;
            mem[22] <= '0;
            mem[23] <= '0;
            mem[24] <= '0;
            mem[25] <= '0;
            mem[26] <= '0;
            mem[27] <= '0;
            mem[28] <= '0;
            mem[29] <= '0;
            mem[30] <= '0;
            mem[31] <= '0;
        end
        else if ( write_en_3 ) begin
            mem[i_addr_3] <= i_write_data_3;
            mem[ 0 ] <= '0;
        end
    end

    // Read logic.
    assign o_read_data_1 = mem[i_addr_1];
    assign o_read_data_2 = mem[i_addr_2];

    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ---------------------------------------------------------------------
// This is a nonarchitectural register with write enable signal for PC.
// ---------------------------------------------------------------------

module ysyx_201979054_register_pc
// Parameters.
#(
    parameter DATA_WIDTH = 64
)
// Port decleration. 
(   
    // Common clock & enable signal.
    input  logic                      clk,
    input  logic                      write_en,
    input  logic                      arst,

    //Input interface. 
    input  logic [ DATA_WIDTH - 1:0 ] i_write_data,
    
    // Output interface.
    output logic [ DATA_WIDTH - 1:0 ] o_read_data
);

    // Write logic.
    always_ff @( posedge clk, posedge arst ) begin 
        if ( arst ) o_read_data <= 64'h3000_0000;
        else if ( write_en ) begin
            o_read_data <= i_write_data;
        end
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ----------------------------------------------------------------------------------------------
// This is a reset syncronizer module.
// ----------------------------------------------------------------------------------------------

module ysyx_201979054_reset_sync 
(
    input  logic clk,
    input  logic arst,
    output logic arst_sync
);

    logic rst_signal;

    always_ff @( posedge clk, posedge arst ) begin
        if ( arst ) { arst_sync, rst_signal } <= 2'b11;
        else        { arst_sync, rst_signal } <= { rst_signal, 1'b0 };
    end
    
endmodule/* Copyright (c) 2024 Maveric NU. All rights reserved. */

// ---------------------------------------------------------------------------------------
// This is a top module in RISC-V architecture. It connects datapath units & control unit.
// ---------------------------------------------------------------------------------------

module ysyx_201979054_datapath
// Parameters. 
#(
    parameter REG_DATA_WIDTH   = 64,
              REG_ADDR_WIDTH   = 5,
              MEM_DATA_WIDTH   = 64,
              MEM_INSTR_WIDTH  = 32,
              MEM_ADDR_WIDTH   = 64,
              OUT_ADDR_WIDTH   = 32,
              BLOCK_DATA_WIDTH = 512


)
// Port declerations. 
(
    //Clock & Reset signals. 
    input  logic                            clk,
    input  logic                            arst,
    input  logic                            i_done_axi,   // NEEDS TO BE CONNECTED TO AXI 
    input  logic [ BLOCK_DATA_WIDTH - 1:0 ] i_data_read_axi,   // NEEDS TO BE CONNECTED TO AXI
    input  logic [ REG_DATA_WIDTH   - 1:0 ] i_data_non_cacheable,
    output logic [                    7:0 ] o_data_non_cacheable,
    output logic                            o_start_read_axi,  // NEEDS TO BE CONNECTED TO AXI
    output logic                            o_start_write_axi, // NEEDS TO BE CONNECTED TO AXI
    output logic                            o_start_read_axi_nc,
    output logic                            o_start_write_axi_nc,
    output logic [ OUT_ADDR_WIDTH   - 1:0 ] o_addr, // JUST FOR SIMULATION
    output logic [ OUT_ADDR_WIDTH   - 1:0 ] o_addr_non_cacheable,
    output logic [ BLOCK_DATA_WIDTH - 1:0 ] o_data_write_axi   // NEEDS TO BE CONNECTED TO AXI
);

    //------------------------
    // INTERNAL NETS.
    //------------------------

    // Instruction cache signals.
    logic s_instr_cache_we;
    logic s_instr_hit;
    logic [ MEM_INSTR_WIDTH - 1:0 ] s_instr_read;

    // Data cache signals.
    logic       s_data_hit;
    logic       s_data_dirty;
    logic       s_data_block_write_en;
    logic       s_data_valid_update;
    logic       s_data_lru_update;
    logic       s_addr_control;
    logic [2:0] s_addr_offset;

    // ALU flags.
    logic s_zero_flag;
    logic s_slt_flag;
    logic s_sltu_flag;

    // Control unit signals. 
    logic [6:0] s_op;
    logic [2:0] s_func_3;
    logic [4:0] s_alu_control;
    logic [2:0] s_result_src;
    logic [1:0] s_alu_src_control_1;
    logic [1:0] s_alu_src_control_2;
    logic [2:0] s_imm_src;
    logic       s_reg_write_en;
    logic       s_pc_write_en;
    logic       s_mem_write_en;
    logic       s_instr_write_en;
    logic       s_fetch_state;

    // Memory signals.
    logic [ MEM_DATA_WIDTH  - 1:0 ] s_mem_read_data;
    logic [ OUT_ADDR_WIDTH - 1:0 ] s_addr_axi;
    logic [ OUT_ADDR_WIDTH - 1:0 ] s_out_addr;
    logic [ MEM_ADDR_WIDTH  - 1:0 ] s_reg_mem_addr;
    logic                           s_reg_mem_addr_we;

    // Register file signals. 
    logic [ REG_ADDR_WIDTH - 1:0 ] s_reg_addr_1;
    logic [ REG_ADDR_WIDTH - 1:0 ] s_reg_addr_2;
    logic [ REG_ADDR_WIDTH - 1:0 ] s_reg_addr_3;
    logic [ REG_DATA_WIDTH - 1:0 ] s_reg_read_data_1;
    logic [ REG_DATA_WIDTH - 1:0 ] s_reg_read_data_2;

    // ALU signals.
    logic [ REG_DATA_WIDTH - 1:0 ] s_alu_src_data_1;
    logic [ REG_DATA_WIDTH - 1:0 ] s_alu_src_data_2;
    logic [ REG_DATA_WIDTH - 1:0 ] s_alu_result;

    // Registered signals. 
    logic [ MEM_INSTR_WIDTH - 1:0 ] s_reg_instr;
    logic [ MEM_ADDR_WIDTH  - 1:0 ] s_reg_pc;
    logic [ MEM_ADDR_WIDTH  - 1:0 ] s_reg_old_pc;
    logic [ MEM_ADDR_WIDTH  - 1:0 ] s_reg_pc_val;
    logic [ REG_DATA_WIDTH  - 1:0 ] s_reg_data_1;
    logic [ REG_DATA_WIDTH  - 1:0 ] s_reg_data_2;
    logic [ REG_DATA_WIDTH  - 1:0 ] s_reg_alu_result;
    logic [ MEM_DATA_WIDTH  - 1:0 ] s_reg_mem_data;
    logic                           s_reg_mem_we;

    // MUX signals.
    logic [ REG_DATA_WIDTH - 1:0 ] s_result;
    logic [ REG_DATA_WIDTH - 1:0 ] s_mem_data;

    // Immediate extend unit signals. 
    logic [                  24:0 ] s_imm;
    logic [ REG_DATA_WIDTH  - 1:0 ] s_imm_ext;

    // LOAD instruction mux unit signal.
    logic [ MEM_DATA_WIDTH - 1:0] s_mem_load_data;

    // CSR signals.
    logic [                  2:0 ] s_csr_write_addr_1;
    logic [                  2:0 ] s_csr_write_addr_2;
    logic                          s_csr_we_1;
    logic                          s_csr_we_2;
    logic                          s_csr_reg_we;
    logic [                  2:0 ] s_csr_read_addr;
    logic [ REG_DATA_WIDTH - 1:0 ] s_csr_read_data;
    logic [ REG_DATA_WIDTH - 1:0 ] s_csr_read_data_reg;
    logic [ REG_DATA_WIDTH - 1:0 ] s_csr_jamp_addr;
    logic [ REG_DATA_WIDTH - 1:0 ] s_csr_mcause;
    logic [                  3:0 ] s_mcause;
    logic                          s_mret_instr;
    logic                          s_csr_writable;

    // Cacheable mark.
    logic s_cacheable_flag;
    logic s_invalidate_instr;

    // CLINT Signals.
    logic s_clint_mmio_flag;
    logic s_clint_write_en;
    logic [ REG_DATA_WIDTH - 1:0 ] s_clint_read_data;

    // CLINT machine timer interrupt.
    logic s_interrupt;
    logic s_timer_int_call;
    logic s_software_int_call;
    logic s_timer_int;
    logic s_software_int;
    logic s_mie_mstatus;
    logic s_mtip_mip;
    logic s_msip_mip;
    logic s_mtie_mie;
    logic s_msie_mie;

    // Exception cause signals.
    logic s_instr_addr_ma;
    logic s_store_addr_ma;
    logic s_load_addr_ma;
    logic s_illegal_instr_load;

    // Fence WB signals.
    logic s_start_wb;
    logic s_done_wb;
    logic s_done_fence;




    //----------------------------------
    // Continious assignmnets. 
    //----------------------------------
    assign s_imm         = s_reg_instr[31:7 ];
    assign s_op          = s_reg_instr[ 6:0 ];
    assign s_func_3      = s_reg_instr[14:12];   
    assign s_reg_addr_1  = s_reg_instr[19:15];
    assign s_reg_addr_2  = s_reg_instr[24:20];
    assign s_reg_addr_3  = s_reg_instr[11:7 ];

    assign s_addr_offset = s_reg_mem_addr[2:0];
    
    assign s_csr_jamp_addr  = ( s_csr_read_data >> 2 ) << 2;
    assign s_csr_mcause     = { s_interrupt, 59'b0, s_mcause };
    assign s_timer_int      = s_mie_mstatus & s_mtip_mip & s_mtie_mie;
    assign s_software_int   = s_mie_mstatus & s_msip_mip & s_msie_mie;


    assign s_cacheable_flag  = ( s_reg_mem_addr >= 64'h3000_0000 );
    assign s_clint_mmio_flag = ( s_reg_mem_addr >= 64'h0200_0000 ) & ( s_reg_mem_addr <= 64'h0200_ffff );

    assign o_addr_non_cacheable = s_reg_mem_addr [ OUT_ADDR_WIDTH - 1:0 ];
    assign o_data_non_cacheable = s_reg_data_2 [ 7:0 ];

    assign s_mem_data = s_cacheable_flag ? s_reg_mem_data : ( s_clint_mmio_flag ? s_clint_read_data : i_data_non_cacheable);

    assign s_reg_pc_val = s_fetch_state ? s_reg_pc : s_reg_old_pc;


 


    //-----------------------------------
    // LOWER LEVEL MODULE INSTANTIATIONS.
    //-----------------------------------


    //---------------------------
    // Control Unit Instance.
    //---------------------------
    ysyx_201979054_control_unit CU (
        .clk                    ( clk                   ), 
        .arst                   ( arst                  ),
        .i_instr_22_20          ( s_reg_instr[22:20]    ),
        .i_op                   ( s_op                  ),
        .i_func_3               ( s_func_3              ),
        .i_func7_6_4            ( s_reg_instr[31:29]    ),
        .i_func7_1_0            ( s_reg_instr[26:25]    ),
        .i_pred_0               ( s_reg_instr[24]       ),
        .i_zero_flag            ( s_zero_flag           ),
        .i_slt_flag             ( s_slt_flag            ),
        .i_sltu_flag            ( s_sltu_flag           ),
        .i_instr_hit            ( s_instr_hit           ),
        .i_read_last_axi        ( i_done_axi            ),
        .i_data_hit             ( s_data_hit            ),
        .i_data_dirty           ( s_data_dirty          ),
        .i_b_resp_axi           ( i_done_axi            ),
        .i_instr_addr_ma        ( s_instr_addr_ma       ),
        .i_store_addr_ma        ( s_store_addr_ma       ),
        .i_load_addr_ma         ( s_load_addr_ma        ),
        .i_illegal_instr_load   ( s_illegal_instr_load  ),
        .i_timer_int            ( s_timer_int           ),
        .i_software_int         ( s_software_int        ),
        .i_cacheable_flag       ( s_cacheable_flag      ),
        .i_clint_mmio_flag      ( s_clint_mmio_flag     ),
        .i_done_fence           ( s_done_fence          ),
        .o_alu_control          ( s_alu_control         ),
        .o_result_src           ( s_result_src          ),
        .o_alu_src_1            ( s_alu_src_control_1   ),
        .o_alu_src_2            ( s_alu_src_control_2   ),
        .o_imm_src              ( s_imm_src             ),
        .o_reg_write_en         ( s_reg_write_en        ),
        .o_pc_write             ( s_pc_write_en         ),
        .o_instr_write_en       ( s_instr_write_en      ),
        .o_mem_write_en         ( s_mem_write_en        ),
        .o_instr_cache_write_en ( s_instr_cache_we      ),
        .o_start_read_axi       ( o_start_read_axi      ),
        .o_block_write_en       ( s_data_block_write_en ),
        .o_data_valid_update    ( s_data_valid_update   ),
        .o_data_lru_update      ( s_data_lru_update     ),
        .o_start_write_axi      ( o_start_write_axi     ),
        .o_addr_control         ( s_addr_control        ),
        .o_mem_reg_we           ( s_reg_mem_we          ),
        .o_fetch_state          ( s_fetch_state         ),
        .o_reg_mem_addr_we      ( s_reg_mem_addr_we     ),
        .o_start_read_nc        ( o_start_read_axi_nc   ),
        .o_start_write_nc       ( o_start_write_axi_nc  ),
        .o_invalidate_instr     ( s_invalidate_instr    ),
        .o_write_en_clint       ( s_clint_write_en      ),
        .o_mret_instr           ( s_mret_instr          ),
        .o_interrupt            ( s_interrupt           ),
        .o_done_wb              ( s_done_wb             ),
        .o_start_wb             ( s_start_wb            ),
        .o_csr_writable         ( s_csr_writable        ),
        .o_mcause               ( s_mcause              ),
        .o_csr_we_1             ( s_csr_we_1            ),
        .o_csr_we_2             ( s_csr_we_2            ),
        .o_csr_reg_we           ( s_csr_reg_we          ),
        .o_csr_write_addr_1     ( s_csr_write_addr_1    ),
        .o_csr_write_addr_2     ( s_csr_write_addr_2    ),
        .o_csr_read_addr        ( s_csr_read_addr       )
    );



    //--------------------------------
    // Data Storage Unit Instances. 
    //--------------------------------

    // Register File Instance.
    ysyx_201979054_register_file REG_FILE (
        .clk            ( clk               ),
        .write_en_3     ( s_reg_write_en    ),
        .arst           ( arst              ),
        .i_addr_1       ( s_reg_addr_1      ),
        .i_addr_2       ( s_reg_addr_2      ),
        .i_addr_3       ( s_reg_addr_3      ),
        .i_write_data_3 ( s_result          ),
        .o_read_data_1  ( s_reg_read_data_1 ),
        .o_read_data_2  ( s_reg_read_data_2 )
    );

    // Data Cache.
    ysyx_201979054_data_cache D_CACHE (
        .clk             ( clk                   ),
        .arst            ( arst                  ),
        .write_en        ( s_mem_write_en        ),
        .valid_update    ( s_data_valid_update   ),
        .lru_update      ( s_data_lru_update     ),
        .block_write_en  ( s_data_block_write_en ),
        .i_data_addr     ( s_reg_mem_addr        ),
        .i_data          ( s_reg_data_2          ),
        .i_data_block    ( i_data_read_axi       ),
        .i_store_type    ( s_func_3[1:0]         ),
        .i_addr_control  ( s_addr_control        ),
        .i_start_wb      ( s_start_wb            ),
        .i_done_wb       ( s_done_wb             ),
        .o_data          ( s_mem_read_data       ),
        .o_data_block    ( o_data_write_axi      ),
        .o_hit           ( s_data_hit            ),
        .o_dirty         ( s_data_dirty          ),
        .o_addr_axi      ( s_addr_axi            ),
        .o_done_fence    ( s_done_fence          ),
        .o_store_addr_ma ( s_store_addr_ma       )
    );

    // Instruction Cache.
    ysyx_201979054_instr_cache I_CACHE (
        .clk                ( clk                ),
        .write_en           ( s_instr_cache_we   ),
        .arst               ( arst               ),
        .i_instr_addr       ( s_reg_pc           ),
        .i_inst             ( i_data_read_axi    ),
        .i_invalidate_instr ( s_invalidate_instr ),
        .o_instr            ( s_instr_read       ),
        .o_hit              ( s_instr_hit        ),
        .o_instr_addr_ma    ( s_instr_addr_ma    )
    );


    // Control & Status Registers.
    ysyx_201979054_csr_file CSR0 (
        .clk                 ( clk                 ),
        .write_en_1          ( s_csr_we_1          ),
        .write_en_2          ( s_csr_we_2          ),
        .arst                ( arst                ),
        .i_read_addr         ( s_csr_read_addr     ),
        .i_write_addr_1      ( s_csr_write_addr_1  ),
        .i_write_addr_2      ( s_csr_write_addr_2  ),
        .i_write_data_1      ( s_csr_mcause        ),
        .i_write_data_2      ( s_result            ),
        .i_timer_int_call    ( s_timer_int_call    ),
        .i_software_int_call ( s_software_int_call ),
        .i_interrupt_jump    ( s_interrupt         ),
        .i_mret_instr        ( s_mret_instr        ),
        .i_writable          ( s_csr_writable      ),
        .o_read_data         ( s_csr_read_data     ),
        .o_mie_mstatus       ( s_mie_mstatus       ),
        .o_mtip_mip          ( s_mtip_mip          ),
        .o_msip_mip          ( s_msip_mip          ),
        .o_mtie_mie          ( s_mtie_mie          ),
        .o_msie_mie          ( s_msie_mie          )
    );


    // CLINT MMIO.
    ysyx_201979054_clint_mmio CLINT0 (
        .clk                 ( clk                     ),
        .arst                ( arst                    ),
        .write_en            ( s_clint_write_en        ),
        .i_addr              ( s_reg_mem_addr[ 14:13 ] ),
        .i_data              ( s_reg_data_2            ),
        .o_data              ( s_clint_read_data       ),
        .o_timer_int_call    ( s_timer_int_call        ),
        .o_software_int_call ( s_software_int_call     )
    );



    //------------------------------
    // ALU Instance. 
    //------------------------------
    ysyx_201979054_alu ALU (   
        .alu_control     ( s_alu_control    ),
        .i_src_1         ( s_alu_src_data_1 ),
        .i_src_2         ( s_alu_src_data_2 ),
        .o_alu_result    ( s_alu_result     ),
        .o_zero_flag     ( s_zero_flag      ),
        .o_slt_flag      ( s_slt_flag       ),
        .o_sltu_flag     ( s_sltu_flag      )
    );



    //-----------------------------------------
    // Nonarchitectural Register Instances. 
    //-----------------------------------------

    // Instruction Register Instance. 
    ysyx_201979054_register_en # (.DATA_WIDTH (MEM_INSTR_WIDTH)) INSTR_REG (
        .clk          ( clk              ),
        .write_en     ( s_instr_write_en ),
        .arst         ( arst             ),
        .i_write_data ( s_instr_read     ),
        .o_read_data  ( s_reg_instr      )
    );

    // PC Register Instance.
    ysyx_201979054_register_pc # (.DATA_WIDTH (MEM_ADDR_WIDTH)) PC_REG (
        .clk          ( clk           ),
        .write_en     ( s_pc_write_en ),
        .arst         ( arst          ),
        .i_write_data ( s_result      ),
        .o_read_data  ( s_reg_pc      )
    ); 

    // Old PC Register Instance.
    ysyx_201979054_register_en # (.DATA_WIDTH (MEM_ADDR_WIDTH)) OLD_PC_REG (
        .clk          ( clk              ),
        .write_en     ( s_instr_write_en ),
        .arst         ( arst             ),
        .i_write_data ( s_reg_pc         ),
        .o_read_data  ( s_reg_old_pc     )
    );

    // MEM ADDR Register Instance.
    ysyx_201979054_register_en MEM_ADDR_REG (
        .clk          ( clk               ),
        .write_en     ( s_reg_mem_addr_we ),
        .arst         ( arst              ),
        .i_write_data ( s_result          ),
        .o_read_data  ( s_reg_mem_addr    )   
    ); 

    // CSR Register Instance.
    ysyx_201979054_register_en # (.DATA_WIDTH (REG_DATA_WIDTH)) CSR_REG (
        .clk          ( clk                 ),
        .write_en     ( s_csr_reg_we        ),
        .arst         ( arst                ),
        .i_write_data ( s_csr_read_data     ),
        .o_read_data  ( s_csr_read_data_reg )
    );  

    // Output addr Register Instance.
    ysyx_201979054_register #(.DATA_WIDTH (OUT_ADDR_WIDTH)) OUTADDR_REG (
        .clk          ( clk        ),
        .arst         ( arst       ),
        .i_write_data ( s_out_addr ),
        .o_read_data  ( o_addr     )
    ); 

    // R1 Register Instance.
    ysyx_201979054_register R1 (
        .clk          ( clk               ),
        .arst         ( arst              ),
        .i_write_data ( s_reg_read_data_1 ),
        .o_read_data  ( s_reg_data_1      )
    );

    // R2 Register Instance.
    ysyx_201979054_register R2 (
        .clk          ( clk               ),
        .arst         ( arst              ),
        .i_write_data ( s_reg_read_data_2 ),
        .o_read_data  ( s_reg_data_2      )
    );

    // ALU Result Register Instance.
    ysyx_201979054_register REG_ALU_RESULT (
        .clk          ( clk              ),
        .arst         ( arst             ),
        .i_write_data ( s_alu_result     ),
        .o_read_data  ( s_reg_alu_result )
    );

    // Memory Data Register. 
    ysyx_201979054_register_en REG_MEM_DATA (
        .clk          ( clk                ),
        .arst         ( arst               ),
        .write_en     ( s_reg_mem_we       ),
        .i_write_data ( s_mem_load_data    ),
        .o_read_data  ( s_reg_mem_data     )
    );



    //----------------------
    // MUX Instances.
    //----------------------

    // 4-to-1 ALU Source 1 MUX Instance.
    ysyx_201979054_mux4to1 ALU_MUX_1 (
        .control_signal ( s_alu_src_control_1 ),
        .i_mux_0        ( s_reg_pc            ),
        .i_mux_1        ( s_reg_old_pc        ),
        .i_mux_2        ( s_reg_data_1        ),
        .i_mux_3        ( s_imm_ext           ),
        .o_mux          ( s_alu_src_data_1    )
    );

    // 4-to-1 ALU Source 2 MUX Instance.
    ysyx_201979054_mux4to1 ALU_MUX_2 (
        .control_signal ( s_alu_src_control_2 ),
        .i_mux_0        ( s_reg_data_2        ),
        .i_mux_1        ( s_imm_ext           ),
        .i_mux_2        ( 64'b0100            ),
        .i_mux_3        ( s_csr_read_data     ),
        .o_mux          ( s_alu_src_data_2    )
    );

    // 8-to-1 Result Source MUX Instance.
    ysyx_201979054_mux8to1 RESULT_MUX (
        .control_signal ( s_result_src        ),
        .i_mux_0        ( s_reg_alu_result    ),
        .i_mux_1        ( s_mem_data          ), 
        .i_mux_2        ( s_alu_result        ),
        .i_mux_3        ( s_imm_ext           ),
        .i_mux_4        ( s_csr_read_data     ),
        .i_mux_5        ( s_csr_read_data_reg ),
        .i_mux_6        ( s_reg_pc_val        ),
        .i_mux_7        ( s_csr_jamp_addr     ),
        .o_mux          ( s_result            ) 
    );




    //---------------------------------------
    // Immiediate Extension Module Instance.
    //---------------------------------------
    ysyx_201979054_extend_imm I_EXT (
        .control_signal ( s_imm_src ),
        .i_imm          ( s_imm     ),
        .o_imm_ext      ( s_imm_ext )
    );

    //------------------------------
    // LOAD Instruction mux. 
    //------------------------------
    ysyx_201979054_load_mux LOAD_MUX (
        .i_func_3        ( s_func_3             ),
        .i_data          ( s_mem_read_data      ),
        .i_addr_offset   ( s_addr_offset        ),
        .o_data          ( s_mem_load_data      ),
        .o_load_addr_ma  ( s_load_addr_ma       ),
        .o_illegal_instr ( s_illegal_instr_load )
    );


    // FOR SIMULATION. 
    assign s_out_addr = s_fetch_state ? { s_reg_pc[ OUT_ADDR_WIDTH - 1:6 ], 6'b0 } : s_addr_axi; // For a cache line size of 512 bits. e.g. 16 words in 1 line.
    
endmodule