
//TEST
class base_test extends uvm_test;

	`uvm_component_utils(base_test)
	
	//Handle declaration
	env		envh;

	env_config	env_cfg;
	tx_config	tx_cfg;
	rx_config	rx_cfg;

	//FLAGS Declaration
	bit has_tx_agent = 1;
	bit has_rx_agent = 1;
	bit has_scoreboard = 1;
	bit has_virtual_sequencer = 1;

	//
	extern function new (string name = "base_test" , uvm_component parent);
	extern function void config_model();
	extern function void build_phase (uvm_phase phase);
endclass

//Constructor
function base_test::new(string name = "base_test", uvm_component parent);
	super.new(name,parent);
endfunction

//MODEL CONFIGURATION
function void base_test::config_model();
	
	if(has_tx_agent)
	begin
	tx_cfg.is_active = UVM_ACTIVE;
	if(!uvm_config_db #(virtual uart_if) :: get(this, "", "vif", tx_cfg.vif))
	begin
	`uvm_fatal("TX CONFIG","CANNOT GET DATA IN VIF. HAVE YOU SET IT?")
	end
	env_cfg.tx_cfg = tx_cfg;	//Assign TX agent configuration object (tx_cfg) to local tx_cfg inside environment
	end

	if(has_rx_agent)
	begin
	rx_cfg.is_active = UVM_PASSIVE;
	if(!uvm_config_db #(virtual uart_if) :: get(this, "", "vif", rx_cfg.vif))
	begin
	`uvm_fatal("RX CONFIG","CANNOT GET DATA IN VIF. HAVE YOU SET IT?")
	end
	env_cfg.rx_cfg = rx_cfg;	//Assign TX agent configuration object (tx_cfg) to local tx_cfg inside environment
	end

	env_cfg.has_tx_agent = has_tx_agent;
	env_cfg.has_rx_agent = has_rx_agent;
	env_cfg.has_scoreboard = has_scoreboard;
	env_cfg.has_virtual_sequencer = has_virtual_sequencer;

	uvm_config_db #(env_config) :: set(this,"*","env_config",env_cfg);
endfunction

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);

//OBJECT CREATION FOR CONFIGURATION BLOCK
	env_cfg = env_config::type_id::create("env_cfg");

	if(has_tx_agent)
	begin
	tx_cfg = tx_config::type_id::create("tx_cfg");
	end

	if(has_rx_agent)
	begin
	rx_cfg = rx_config::type_id::create("rx_cfg");
	end
	
	config_model();

	envh = env::type_id::create("envh",this);
endfunction


//TEST CASE 1: RANDOM TX 
class random_tx_test extends base_test;

	`uvm_component_utils(random_tx_test)

	v_random_tx_seq 	random_testh;

	extern function new(string name = "random_tx_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

////CONSTRUCTOR FOR TC_1
function random_tx_test::new(string name = "random_tx_test", uvm_component parent);
	super.new(name,parent);
endfunction

////BUILD PHASE FOR TC_1
function void random_tx_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

////RUN PHASE FOR TC_1
task random_tx_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);			//RAISE OBJECTION
	random_testh=v_random_tx_seq::type_id::create("random_testh");
	random_testh.start(envh.v_seqr);
	phase.drop_objection(this);			//DROP OBJECTION
endtask

//TEST CASE 2: DIRECTED TX 
class directed_tx_test extends base_test;

	`uvm_component_utils(directed_tx_test)

	v_directed_tx_seq 	directed_testh;

	extern function new(string name = "directed_tx_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

////CONSTRUCTOR FOR TC_2
function directed_tx_test::new(string name = "directed_tx_test", uvm_component parent);
	super.new(name,parent);
endfunction

////BUILD PHASE FOR TC_2
function void directed_tx_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

////RUN PHASE FOR TC_2
task directed_tx_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);			//RAISE OBJECTION
	directed_testh=v_directed_tx_seq::type_id::create("directed_testh");
	directed_testh.start(envh.v_seqr);
	phase.drop_objection(this);			//DROP OBJECTION
endtask