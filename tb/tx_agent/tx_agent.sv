//TX AGENT

class tx_agent extends uvm_agent;

	`uvm_component_utils(tx_agent)

	tx_config	tx_cfg;
	tx_driver	tx_drv;
	tx_monitor	tx_mon;
	tx_sequencer	seqrh;

	extern function new(string name = "tx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function tx_agent::new(string name = "tx_agent", uvm_component parent);
	super.new(name,parent);
endfunction

function void tx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(tx_config)::get(this,"","tx_config",tx_cfg))
	begin
	`uvm_fatal("TX AGENT","CANNOT GET DATA FROM TX_CONFIG. HAVE YOU SET IT?")
	end

	tx_mon = tx_monitor::type_id::create("tx_mon",this);

	if(tx_cfg.is_active == UVM_ACTIVE)
	begin
	tx_drv = tx_driver::type_id::create("tx_drv",this);
	seqrh = tx_sequencer::type_id::create("seqrh",this);
	end

	//SETTING DATA FOR DRIVER AND MONITOR
	uvm_config_db #(tx_config)::set(this,"tx_mon","tx_config",tx_cfg);
	if(tx_cfg.is_active == UVM_ACTIVE)
	uvm_config_db #(tx_config)::set(this,"tx_drv","tx_config",tx_cfg);
endfunction

function void tx_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	if(tx_cfg.is_active == UVM_ACTIVE)
	begin
	tx_drv.seq_item_port.connect(seqrh.seq_item_export);
	end
endfunction

