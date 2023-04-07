# Author: Kyle Parato
# Email:  kparato@csu.fullerton.edu
# Date started: 2/7/2023
# Last updated: 3/7/2023
# 
# ubuntu  version 20.04
# yasm    version 1.3.0
# GNU ld  version 2.34
# GNU DDD version 3.3.12
# 
# Description: This shell script grabs all .asm complies them
# using yasm and runs them together or seperatly based off of
# user input 

# Welcome message with warning about rm command
echo "Welcome, make sure you have yasm, ld, and ddd installed"
echo ""
echo "IMPORTANT NOTICE!!"
echo "This script will remove all .o, .lst, and .out in directory, if you do not want this please select 0 to exit."
echo "If you want to remove this feature, remove the block of code under that containts the rm command. Line(33-38)" 
echo ""
# Prompting user to determine how to assemble files
echo "Welcome, please choose an option below"
echo "1: compile together"
echo "2: compile seperatly"
echo "0: exit program"
read choice
echo ""

# Continues code if zero is not inputed
if [ $choice != '0' ]; then

    # This block removes all past files
    echo "Removing .o, .lst, and .out files"
    rm *.out                                        # REMOVE THESE IF YOU DONT WANT FILES AUTOMATICALLY CLEANED UP
    rm *.lst
    rm *.o
    echo ""

    # This block finds all .asm files  in folder and compiles them into
    # .o files for linking, if there are no .asm files the block is skipped 
    asmFiles=( $(find ./ -path ./.\* -prune -o -name "*.asm") ) # Finds all .asm in directory and stores them into an array
    if [ ${#asmFiles[@]} -ne 0 ]; then                                     # Checks if the array is not empty
        echo "Compiling .asm files"
        for fileName in ${asmFiles[@]}; do                                 # Searches through the array to grab the file name
            file=${fileName:2}                                             # file name is stored as ./file.asm, this line removes the ./ 
            echo "  Assembling: $file"
            eval  yasm -g dwarf2 -f elf64 ${file%.*}.asm -l ${file%.*}.lst # Command to compile, the ${file%.*} removes the .asm
        done
        echo ""
    fi

    # This block finds all .o files in folder and links them, then calls the dubugger
    objects=( $(find ./ -path ./.\* -prune -o -name "*.o") ) # Finds all .o in directory and stores them into an array
    #if link together
    if [ $choice = '1' ]; then
        # This block finds all .o files in folder and links them, then calls the dubugger
        objects=( $(find ./ -path ./.\* -prune -o -name "*.o") ) # Finds all .o in directory and stores them into an array
        if [ ${#objects[@]} -ne 0 ]; then  # Checks if the array is not empty
            echo "Linking"
            link="ld -g -o run.out "       # String to store the command, will append all .o files to the end of the command
            for obj in ${objects[@]}; do   # Searches through the array to grab the file name
                echo "  Linking: ${obj:2}" 
                link+=${obj:2}             # file name is stored as ./file.o, this line removes the ./ and adds the file to the command
                link+=" "                  # adds a space to seperate .o files
            done

            eval $link                     # runs command to link .o files

            echo ""
            echo "Running Program"
            echo ""
            ./run.out                      # runs the program
            echo ""

            # Prompt user to see if they want to use debugger
            echo -n "Continue to debugger? y/n: " 
            read response
            echo ""

            # Checks if user wants to use debugger
            if [ $response = "y" ]; then
                echo "Trying Debugger"
                ddd run.out               # Command to run ddd on file
            fi
        fi 
    fi

    # link seperate
    if [ $choice = '2' ]; then
        if [ ${#objects[@]} -ne 0 ]; then   # Checks if the array is not empty
            echo "Linking"
            #link="ld -g -o run.out "       # String to store the command, will append all .o files to the end of the command
            for obj in ${objects[@]}; do    # Searches through the array to grab the file name
                echo "  Linking: ${obj:2}" 
                o=${obj:2}
                #link+=${obj:2}             # file name is stored as ./file.o, this line removes the ./ and adds the file to the command
                #link+=" "                  # adds a space to seperate .o files
                eval ld -g -o ${o%.*}.out $o
            done

            run=( $(find ./ -path ./.\* -prune -o -name "*.out") ) #finds all .out files in directory
            if [ ${#run[@]} -ne 0 ]; then   #checks if array is not empty
                for r in  ${run[@]}; do     #iterates through all .out files and runs them
                    echo ""
                    echo "Running Program: ${r:2}"
                    echo ""
                    eval $r                 # runs the program
                    echo ""

                    # Prompt user to see if they want to use debugger
                    echo -n "Continue to debugger? y/n: " 
                    read response
                    echo ""
                    # Checks if user wants to use debugger
                        if [ $response = "y" ]; then
                            echo "Trying Debugger"
                            eval ddd ${r:2}               # Command to run ddd on file
                        fi  
                done
            fi 
        fi
    fi
fi
echo "End of program, have a nice day!"