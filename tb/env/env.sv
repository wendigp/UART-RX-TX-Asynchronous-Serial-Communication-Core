//ENVIRONMENT

class env extends uvm_env;

	`uvm_component_utils(env)

	//Components Declaration
	tx_agent 		tx_agt;
	rx_agent		rx_agt;

	scoreboard		sb;
	v_sequencer	v_seqr;
	env_config		env_cfg;

	extern function new(string name = "env", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern function void report_phase(uvm_phase phase);
endclass

function env::new(string name = "env", uvm_component parent);
	super.new(name,parent);
endfunction

function void env::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(env_config) :: get(this,"","env_config",env_cfg))
	begin
	`uvm_fatal("ENV","CANNOT GET DATA FROM ENV_CONFIG. HAVE YOU SET IT?")
	end

	if(env_cfg.has_tx_agent)
	begin
	uvm_config_db #(tx_config)::set(this,"tx_agt","tx_config",env_cfg.tx_cfg);
	tx_agt = tx_agent::type_id::create("tx_agt",this);				//OBJECT CREATION FOR TX AGENT
	end

	if(env_cfg.has_rx_agent)
	begin
	uvm_config_db #(rx_config)::set(this,"rx_agt","rx_config",env_cfg.rx_cfg);
	rx_agt = rx_agent::type_id::create("rx_agt",this);				//OBJECT CREATION FOR RX AGENT
	end

	if(env_cfg.has_scoreboard)
	begin
	sb = scoreboard::type_id::create("sb",this);					//OBJECT CREATION FOR SCOREBOARD
	end

	if(env_cfg.has_virtual_sequencer)
	begin
	v_seqr = v_sequencer::type_id::create("v_seqr",this);
	end
endfunction

function void env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	//CONNECTION OF VIRTUAL SEQUENCER WITH TX_SEQUENCER & RX_SEQUENCER
	if(env_cfg.has_virtual_sequencer)
	begin
	if(env_cfg.has_tx_agent && tx_agt != null)
	v_seqr.tx_seqr = tx_agt.seqrh;  	//tx_seqr is object handle of TX SEQR in virtual seqr , seqrh is object handle of tx_seqr inside tx_agent

	end

	//CONNECTION OF SCOREBOARD WITH TX_MONITOR & RX_MONITOR
	if(env_cfg.has_scoreboard)
	begin
	if(env_cfg.has_tx_agent)
	tx_agt.tx_mon.monitor_port.connect(sb.fifo_tx.analysis_port);
	
	if(env_cfg.has_rx_agent)
	rx_agt.rx_mon.monitor_port.connect(sb.fifo_rx.analysis_port);
	end
endfunction

function void env::report_phase(uvm_phase phase);
	super.report_phase(phase);
	if (uvm_report_enabled(UVM_LOW))
    	uvm_top.print_topology();
endfunction
