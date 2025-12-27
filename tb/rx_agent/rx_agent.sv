//RX AGENT

class rx_agent extends uvm_agent;

	`uvm_component_utils(rx_agent)

	//HANDLE DECLARATION
	rx_config		rx_cfg;
	rx_monitor		rx_mon;
	
	extern function new (string name = "rx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

function rx_agent::new(string name = "rx_agent", uvm_component parent);
	super.new(name,parent);
endfunction

function void rx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(rx_config)::get(this,"","rx_config",rx_cfg))
	begin
	`uvm_fatal("RX AGENT","CANNOT GET DATA FROM RX_CONFIG. HAVE YOU SET IT?")
	end

	rx_mon = rx_monitor::type_id::create("rx_mon",this);


	//SETTING DATA FOR DRIVER AND MONITOR
	uvm_config_db #(rx_config)::set(this,"rx_mon","rx_config",rx_cfg);

endfunction


//Connect phase not needed as RX Agent is passive

