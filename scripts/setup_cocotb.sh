#!/bin/bash
#=============================================================================
# PDM to PCM Decimator Core - Cocotb Setup Script
#=============================================================================
# Description: Setup script for installing cocotb and dependencies
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python_version() {
    if command_exists python3; then
        PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        print_status "Found Python $PYTHON_VERSION"
        
        # Check if version is >= 3.7
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 7 ]); then
            print_error "Python 3.7 or higher is required. Found Python $PYTHON_VERSION"
            exit 1
        fi
    else
        print_error "Python 3 is not installed"
        exit 1
    fi
}

# Function to check pip
check_pip() {
    if command_exists pip3; then
        print_status "Found pip3"
    else
        print_error "pip3 is not installed"
        exit 1
    fi
}

# Function to install Python packages
install_python_packages() {
    print_status "Installing Python packages from requirements.txt..."
    
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt
        print_success "Python packages installed successfully"
    else
        print_warning "requirements.txt not found, installing basic cocotb packages"
        pip3 install cocotb cocotb-bus numpy scipy matplotlib pytest pytest-cov
        print_success "Basic Python packages installed successfully"
    fi
}

# Function to check and install simulators
check_simulators() {
    print_status "Checking for available simulators..."
    
    SIMULATORS=()
    
    # Check Icarus Verilog
    if command_exists iverilog; then
        IVERILOG_VERSION=$(iverilog -V | head -n1)
        print_success "Found Icarus Verilog: $IVERILOG_VERSION"
        SIMULATORS+=("icarus")
    else
        print_warning "Icarus Verilog not found"
    fi
    
    # Check Verilator
    if command_exists verilator; then
        VERILATOR_VERSION=$(verilator --version | head -n1)
        print_success "Found Verilator: $VERILATOR_VERSION"
        SIMULATORS+=("verilator")
    else
        print_warning "Verilator not found"
    fi
    
    # Check Questa/ModelSim
    if command_exists vsim; then
        print_success "Found Questa/ModelSim"
        SIMULATORS+=("questa")
    else
        print_warning "Questa/ModelSim not found"
    fi
    
    # Check VCS
    if command_exists vcs; then
        print_success "Found VCS"
        SIMULATORS+=("vcs")
    else
        print_warning "VCS not found"
    fi
    
    # Check GTKWave
    if command_exists gtkwave; then
        print_success "Found GTKWave"
    else
        print_warning "GTKWave not found (optional for waveform viewing)"
    fi
    
    if [ ${#SIMULATORS[@]} -eq 0 ]; then
        print_error "No simulators found. Please install at least one simulator:"
        echo "  - Icarus Verilog: http://bleyer.org/icarus/"
        echo "  - Verilator: https://verilator.org/"
        echo "  - Questa/ModelSim: https://www.intel.com/content/www/us/en/software-kit/746722/questa-fse-edition-software-kit.html"
        echo "  - VCS: https://www.synopsys.com/verification/simulation/vcs.html"
        exit 1
    else
        print_success "Available simulators: ${SIMULATORS[*]}"
    fi
}

# Function to test cocotb installation
test_cocotb() {
    print_status "Testing cocotb installation..."
    
    # Test basic cocotb functionality
    if python3 -c "import cocotb; print('cocotb version:', cocotb.__version__)" 2>/dev/null; then
        print_success "Cocotb installation verified"
    else
        print_error "Cocotb installation failed"
        exit 1
    fi
    
    # Test cocotb-config
    if command_exists cocotb-config; then
        print_success "cocotb-config found"
    else
        print_warning "cocotb-config not found (may need to add ~/.local/bin to PATH)"
    fi
}

# Function to create virtual environment (optional)
create_venv() {
    if [ "$1" = "--venv" ]; then
        print_status "Creating virtual environment..."
        
        if command_exists python3 -m venv; then
            python3 -m venv venv
            print_success "Virtual environment created: venv/"
            print_status "To activate: source venv/bin/activate"
            print_status "To deactivate: deactivate"
        else
            print_error "python3 -m venv not available"
            exit 1
        fi
    fi
}

# Function to setup development environment
setup_dev_env() {
    print_status "Setting up development environment..."
    
    # Create necessary directories
    mkdir -p build/cocotb
    mkdir -p reports/cocotb
    mkdir -p waveforms/cocotb
    
    # Create .gitignore entries if not present
    if [ ! -f ".gitignore" ]; then
        print_status "Creating .gitignore file..."
        cat > .gitignore << EOF
# Build artifacts
build/
reports/
waveforms/

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
.venv/

# Coverage
.coverage
htmlcov/
coverage.xml

# Simulator files
*.vcd
*.vvp
*.log
*.dump

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
        print_success ".gitignore created"
    fi
    
    # Create pre-commit hook if pre-commit is available
    if command_exists pre-commit; then
        print_status "Setting up pre-commit hooks..."
        pre-commit install
        print_success "Pre-commit hooks installed"
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --venv          Create virtual environment"
    echo "  --dev           Setup development environment"
    echo "  --test          Run quick test after installation"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Basic installation"
    echo "  $0 --venv       # Install in virtual environment"
    echo "  $0 --dev        # Setup development environment"
    echo "  $0 --venv --dev # Full development setup"
}

# Main function
main() {
    print_status "Starting cocotb setup for PDM to PCM Decimator Core"
    print_status "Version: 1.3.0"
    echo ""
    
    # Parse command line arguments
    CREATE_VENV=false
    SETUP_DEV=false
    RUN_TEST=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --venv)
                CREATE_VENV=true
                shift
                ;;
            --dev)
                SETUP_DEV=true
                shift
                ;;
            --test)
                RUN_TEST=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Check system requirements
    print_status "Checking system requirements..."
    check_python_version
    check_pip
    
    # Create virtual environment if requested
    if [ "$CREATE_VENV" = true ]; then
        create_venv --venv
        print_status "Activating virtual environment..."
        source venv/bin/activate
    fi
    
    # Install Python packages
    install_python_packages
    
    # Check simulators
    check_simulators
    
    # Test cocotb installation
    test_cocotb
    
    # Setup development environment if requested
    if [ "$SETUP_DEV" = true ]; then
        setup_dev_env
    fi
    
    # Run quick test if requested
    if [ "$RUN_TEST" = true ]; then
        print_status "Running quick test..."
        if [ -f "tb/cocotb/Makefile" ]; then
            cd tb/cocotb && make quick-test
            cd ../..
            print_success "Quick test completed"
        else
            print_warning "Cocotb testbench not found, skipping test"
        fi
    fi
    
    echo ""
    print_success "Cocotb setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "  1. Run tests: make cocotb-quick"
    echo "  2. Run full regression: make cocotb-regression"
    echo "  3. View help: make help"
    echo ""
    
    if [ "$CREATE_VENV" = true ]; then
        print_warning "Remember to activate virtual environment: source venv/bin/activate"
    fi
}

# Run main function with all arguments
main "$@"
