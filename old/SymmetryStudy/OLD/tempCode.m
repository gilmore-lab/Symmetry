%% BEGIN - Save indexed responseGripMatrix
        notSaved = 1;
        tempCounter = 1;
        while( notSaved )
            tempFilename = ['Response/SPM_Matrix_', num2str( tempCounter ), '.mat'];
            if(   exist( tempFilename )  )
                tempCounter = tempCounter + 1;
                notSaved = 1;
            else              
                SPM_Matrix = char( SPM_Matrix );
                eval(  ['save ', tempFilename, ' SPM_Matrix']  );
                notSaved = 0;
                tempCounter = 1;
            end;  % END - if(   exist( tempFilename )  )         
            %  save responseGripMatrix.mat responseGripMatrix
        end;  % END -     while( notSaved )
    %% END - Save indexed responseGripMatrix