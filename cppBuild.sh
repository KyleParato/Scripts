echo "Removing .o, .lst, and .out files"
rm *.out
rm *.lst
rm *.o

echo ""

echo "Welcome, please choose an option below"
echo "1: compile together"
echo "2: compile seperatly"
echo "0: exit program"
read choice
echo "$choice"
echo ""

if [ $choice != '0' ]; then
    cppFiles=( $(find ./ -path ./.\* -prune -o -name "*.cpp") ) 
    if [ ${#cppFiles[@]} -ne 0 ]; then
        echo "Compiling .cpp files"
        for fileName in ${cppFiles[@]}; do
            file=${fileName:2}
            echo "  Compiling: $file"
            eval  g++ -c ${file%.*}.cpp -l ${file%.*}.lst
        done
        echo ""
    fi


    objects=( $(find ./ -path ./.\* -prune -o -name "*.o") )
    #if together
    if [ $choice = '1' ]; then
        if [ ${#objects[@]} -ne 0 ]; then
            echo "Linking"
            link="g++ -o run.out "
            for obj in ${objects[@]}; do
                echo "  Linking: ${obj:2}"
                link+=${obj:2}
                link+=" "
            done

            eval $link

            echo ""
            echo "Running Program"
            echo ""
            ./run.out
            echo ""


            # echo -n "Continue to debugger? y/n: " 
            # read response
            # echo ""

            # if [ $response = "y" ]; then
            #     echo "Trying Debugger"
            #     ddd run.out
            #fi
        fi 
    fi
    #if seperate
    if [ $choice = '2' ]; then
        if [ ${#objects[@]} -ne 0 ]; then  # Checks if the array is not empty
            echo "Linking"
            #link="ld -g -o run.out "       # String to store the command, will append all .o files to the end of the command
            for obj in ${objects[@]}; do   # Searches through the array to grab the file name
                echo "  Linking: ${obj:2}" 
                o=${obj:2}
                #link+=${obj:2}             # file name is stored as ./file.o, this line removes the ./ and adds the file to the command
                #link+=" "                  # adds a space to seperate .o files
                eval g++ -o ${o%.*}.out $o
            done

            run=( $(find ./ -path ./.\* -prune -o -name "*.out") )
            if [ ${#run[@]} -ne 0 ]; then 
                for r in  ${run[@]}; do
                    echo ""
                    echo "Running Program: ${r:2}"
                    echo ""
                    eval $r                      # runs the program
                    echo ""

                    # # Prompt user to see if they want to use debugger
                    # echo -n "Continue to debugger? y/n: " 
                    # read response
                    # echo ""
                    # #     # # Checks if user wants to use debugger
                    #     if [ $response = "y" ]; then
                    #         echo "Trying Debugger"
                    #         eval ddd ${r:2}               # Command to run ddd on file
                    #     fi  
                done 
            fi
        fi
    fi
fi
echo "End of program"