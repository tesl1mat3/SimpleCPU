`timescale 1ns / 1ps
module SimpleCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);

  parameter SIZE = 10;

  input clk, rst;
  input wire [31:0] data_fromRAM;
  output reg wrEn;
  output reg [SIZE-1:0] addr_toRAM;
  output reg [31:0] data_toRAM;

  `define STATE0 0
  `define STATE1 1
  `define STATE2 2
  `define STATE3 3
  `define STATE4 4
  `define STATE5 5

  reg [7:0] currentState, nextState;
  reg [SIZE-1:0] pc, pcNext; // pc: Program Counter
  reg [31:0] instructionWord, instructionWordNext;
  reg [31:0] regA, regANext;
  reg [31:0] regB, regBNext;

  always@(posedge clk) begin

    if(rst) begin
      currentState <= `STATE0;
      pc <= 0;
      instructionWord <= 0;
      regA <= 0;
      regB <= 0;
    end
    else begin
          currentState <= nextState;
          pc <= pcNext;
          instructionWord <= instructionWordNext;
          regA <= regANext;
          regB <= regBNext;
    end
  end

  always@(*) begin // default values 

      nextState = `STATE0;
      pcNext = pc;
      instructionWordNext = instructionWord;
      regANext = regA; // regA
      regBNext = regB;  // regB
      wrEn = 0;
      addr_toRAM = 0;
      data_toRAM = 0;
    
      case(currentState) 
      `STATE0: begin
              wrEn = 0;
                addr_toRAM = 0;
                data_toRAM = 0;
                pcNext = 0;
                instructionWordNext = 0;
                regANext = 0;
                regBNext = 0;
                nextState = `STATE1;
        end
      
            `STATE1: begin
              addr_toRAM = pc;
              pcNext = pc + 1;
              nextState = `STATE2;
        end

          `STATE2: begin
        if(data_fromRAM [31:29] == 3'b101 &&(~data_fromRAM[28])) begin
                  addr_toRAM = data_fromRAM[13:0]; 
          instructionWordNext = data_fromRAM;
        end
        else begin
                  addr_toRAM = data_fromRAM[27:14];
          instructionWordNext = data_fromRAM;
        end
        
              nextState = `STATE3;
      end
          
      `STATE3: begin // 1 bit control
        regANext = data_fromRAM; 
              if (instructionWord [31:29] == 3'b101 && (instructionWord[28])) begin
                  addr_toRAM = instructionWord [13:0];
                  nextState = `STATE4;
              end
        else if(instructionWord [31:29] == 3'b101 &&(~instructionWord[28])) begin
          addr_toRAM = data_fromRAM;
                  nextState = `STATE4;
        end
              else if(~instructionWord[28]) begin 
          addr_toRAM = instructionWord [13:0];
                  nextState = `STATE4;
            end
        else if (instructionWord [31:29] == 3'b011) begin
          addr_toRAM = instructionWord [13:0];
                  nextState = `STATE4;
        end
 
                else begin
                  nextState = `STATE5;
              end
      end

            `STATE4: begin
                regBNext = data_fromRAM;
                nextState = `STATE5;
      end
      
            `STATE5: begin
            
                case(instructionWord[31:28])  
          {3'b000,1'b0}: begin // operation ADD
            wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA + regB);
          end

                    {3'b000,1'b1}: begin // operation ADDi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA + instructionWord[13:0]);
                    end
                
                    {3'b001,1'b0}: begin // operation NAND
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = ~(regA & regB);
          end
                
                    {3'b001,1'b1}: begin // operation NANDi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = ~(regA & instructionWord[13:0]);
          end
                
                    {3'b011 , 1'b1}: begin // operation LTi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA < instructionWord[13:0]);
          end
            
                    {3'b100,1'b0}:begin // operation CP
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = regB;
                    end
                  
                {3'b100, 1'b1}: begin // operation CPi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = instructionWord[13:0];
                    end
                  
                  {3'b101, 1'b0}: begin // operation CPI
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = regB;
                    end
                  
                {3'b101,1'b1}: begin // operation CPIi
                        wrEn = 1;
                        addr_toRAM = regA;
                    data_toRAM = regB;
                  end
                  
          {3'b110,1'b0}:begin // operation BZJ
                        pc = (regB == 0) ? regA : (pcNext);
                  end
                
                    {3'b110,1'b1}:begin // operation BZJi
            pc = regA + instructionWord[13:0];
          end

                    {3'b111, 1'b0}: begin // operation MUL
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA * regB);
                    end

                    {3'b010, 1'b0}: begin // operation SRL 
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regB < 32) ? ((regA) >> (regB)) : ((regA) << ((regB) - 32));
          end
          
                    {3'b010, 1'b1}: begin // operation SRLi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                      data_toRAM = (instructionWord[13:0] < 32) ? ((regA) >> instructionWord[13:0]) : ((regA) << (instructionWord[13:0] - 32));
          end
                    
                    {3'b011, 1'b0}: begin // operation LT
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA < regB);
                    end
          
                    {3'b111, 1'b1}: begin // operation MULi
                        wrEn = 1;
                        addr_toRAM = instructionWord[27:14];
                        data_toRAM = (regA * instructionWord[13:0]);
          end
        endcase
        nextState= `STATE1;
        end
      endcase
    end
endmodule
 
