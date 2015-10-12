//---------------------------------------------------------------------------
//-- Implementacion del procesador docente SIMPLEZ en verilog
//-- Diseñado para ser sintetizado usando las herramientas libres del 
//-- proyecto icestorm:  http://www.clifford.at/icestorm/
//--
//----------------------------------------------------------------------------
//-- Simplez es una cpu clásica, con la memoria y los periféricos situados
//-- "fuera del chip". Sin embargo, en esta implementación se tomará el 
//-- enfoque de convertir simplez en un "microcontrolador", que disponga en 
//-- su interior de memoria y periféricos
//----------------------------------------------------------------------------
//-- (C) BQ, september 2015. Written by Juan Gonzalez Gomez (Obijuan)
//-- Released under the GPL license
//----------------------------------------------------------------------------
`default_nettype none

module simplez (input wire clk,
                output wire [3:0] leds,
                output reg stop
                );

//-- Anchura de los datos: Bus datos, acumulador, RI
parameter DATAW = 12;

//-- Anchura de las direcciones: Bus direciones, CP, RA
parameter ADDRW = 9;

//---------------------------------------------------------------------
//-- RUTA DE DATOS
//---------------------------------------------------------------------

//--------------- Microordenes
reg lec;
reg era;
reg esc;

//-- Para CP
reg incp;
reg ecp;
reg ccp;
reg scp;

//-- Para RI
reg eri;
reg sri;

//-- para AC
reg eac;
reg sac;

//-- Registro para monitorizar
reg [3:0] leds_r;

//-------- Buses
wire [DATAW-1: 0] busD;   //-- Bus de datos
wire [ADDRW-1: 0] busAi;  //-- Bus de direcciones (interno)

//-- Inicializador
reg rstn = 0;
always @(negedge clk)
  rstn <= 1;

//-------- Registro de direcciones externas
reg [ADDRW-1: 0] RA;

//-------- Registro de instruccion

reg [DATAW-1: 0] RI;

always @(negedge clk)
  if (eri)
    RI <= busD;

//-- Monitorizar RI
always @(negedge clk)
  leds_r <= RI[3:0];

assign leds = leds_r;


//-- Instanciar la memoria principal
memory
  ROM (
        .clk(clk),
        .addr(0),
        .wr(0),
        .data_in(0),
        .data_out(data_out)
      );

wire [11:0] data_out;

/*
//-- Monitorizar bus de datos
always @(negedge clk)
  leds_r <= busD[3:0];

assign leds = leds_r;
*/

//-------- ACCESO AL BUS DE DATOS ----------------------------
assign busD =  (lec) ? data_out :      //-- Conectar la memoria
                       {DATAW{1'b1}};  //-- Valor por defecto


//-----------------------------------------------------------
//-- SECUENCIADOR
//-----------------------------------------------------------

//-- Estados del secuenciador
localparam I0 = 0; //-- Lectura de instruccion. Incremento del PC
localparam I1 = 1; //-- Decodificacion y ejecucion
localparam O0 = 2; //-- Lectura o escritura del operando
localparam O1 = 3; //-- Terminacion del ciclo

//-- Registro de estado
reg state;

always @(negedge clk)

  if (rstn == 0)
    state <= I0;  //--Estado inicial: Lectura de instruccion

  else begin
    case (state)

      I0: state <= I0;

      default:
        state <= I0;
        
    endcase
  end

always @*
  case (state)

    I0: begin 
      stop <= 1;
      lec <= 1;
      eri <= 1;
    end

    default: begin
      stop <= 0;
      lec <= 0;
      eri <= 0;
    end

  endcase


endmodule










