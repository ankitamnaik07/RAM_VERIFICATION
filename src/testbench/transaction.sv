`include "defines.svh"
class ram_transaction;
        rand logic [`DATA_WIDTH-1:0] data_in;
        rand logic [`ADDR_WIDTH-1:0] address;
        rand logic write_enb, read_enb;
        logic [`DATA_WIDTH-1:0] data_out;

        constraint wr_rd_constraint{
                {write_enb,read_enb} inside {[1:2]};
        }

        virtual function ram_transaction copy();
                copy = new();
                copy.data_in = this.data_in;
                copy.address = this.address;
                copy.write_enb = this.write_enb;
                copy.read_enb = this.read_enb;
                copy.data_out = this.data_out;
        endfunction
endclass

class ram_transaction1 extends ram_transaction;
        constraint wr_rd_constraint{
                {write_enb,read_enb} == 2'b01;
        }
        virtual function ram_transaction copy();
                ram_transaction1 copy1 = new();
                copy1.data_in  = this.data_in;
                copy1.address  = this.address;
                copy1.write_enb = this.write_enb;
                copy1.read_enb = this.read_enb;
                copy1.data_out = this.data_out;
                return copy1;
        endfunction
endclass

class ram_transaction2 extends ram_transaction;
        constraint wr_rd_constraint
        {
                {write_enb,read_enb} == 2'b10;
        }
        virtual function ram_transaction copy();
                ram_transaction2 copy2 = new();
                copy2.data_in = this.data_in;
                copy2.address = this.address;
                copy2.write_enb = this.write_enb;
                copy2.read_enb = this.read_enb;
                copy2.data_out = this.data_out;
                return copy2;
        endfunction
endclass

class ram_transaction3 extends ram_transaction;
        constraint wr_rd_constraint{
                {write_enb,read_enb} == 2'b11;
        }
        virtual function ram_transaction copy();
                ram_transaction3 copy3 = new();
                copy3.data_in  = this.data_in;
                copy3.address  = this.address;
                copy3.write_enb = this.write_enb;
                copy3.read_enb = this.read_enb;
                copy3.data_out = this.data_out;
                return copy3;
        endfunction
endclass

class ram_transaction4 extends ram_transaction;
        constraint wr_rd_constraint{
                {write_enb,read_enb} == 2'b00;
        }
        virtual function ram_transaction copy();
                ram_transaction4 copy4 = new();
                copy4.data_in  = this.data_in;
                copy4.address  = this.address;
                copy4.write_enb = this.write_enb;
                copy4.read_enb = this.read_enb;
                copy4.data_out = this.data_out;
                return copy4;
        endfunction
endclass
