function [frame] = simpleui()
% function [frame] = simpleui(runvals)
% javaui.m
% 9/13/13
% Author: Ken Hwang

% Import
import javax.swing.*
import javax.swing.table.*
import java.awt.*

% Set-up JFrame
frame = JFrame('Experiment Info');
callback4 = @(obj,evt)onClose(obj,evt); % Callback for close button
set(frame,'WindowClosingCallback',callback4);
frame.setSize(400,300);
toolkit = Toolkit.getDefaultToolkit();
screenSize = toolkit.getScreenSize();
x = (screenSize.width - frame.getWidth()) / 2;
y = (screenSize.height - frame.getHeight()) / 2;
frame.setLocation(x, y);

% Set-up subject ID entry
tf1Panel = JPanel(GridLayout(1,1));
tf1Panel.setBorder(BorderFactory.createTitledBorder('Subject ID:'));
tf1 = JTextField(datestr(now,30));
tf1Panel.add(tf1);

% Set-up runs entry
tf2Panel = JPanel(GridLayout(1,1));
tf2Panel.setBorder(BorderFactory.createTitledBorder('Number of runs'));
tf2 = JTextField(1);
tf2Panel.add(tf2);

% Set-up interval entry
tf3Panel = JPanel(GridLayout(1,1));
tf3Panel.setBorder(BorderFactory.createTitledBorder('Presentation Interval'));
tf3 = JTextField(1);
tf3Panel.add(tf3);

% Set-up trigger radio buttons
rb1Panel = JPanel(GridLayout(2,1));
rb1Panel.setBorder(BorderFactory.createTitledBorder('Trigger:'));
yes1 = JRadioButton('Yes');
yes1.setActionCommand('Yes');
yes1.setSelected(true);
no1 = JRadioButton('No');
no1.setActionCommand('No');
group1 = ButtonGroup();
group1.add(yes1);
group1.add(no1);
rb1Panel.add(yes1);
rb1Panel.add(no1);

% Set-up left pane
left = JPanel(GridLayout(4,1));
left.setMinimumSize(Dimension(150,225));
left.setPreferredSize(Dimension(150,225));
left.add(tf1Panel);
left.add(tf2Panel);
left.add(tf3Panel);
left.add(rb1Panel);

% % Set-up first right panel
% btn1Panel = JPanel(GridBagLayout());
% gbc = GridBagConstraints();
% gbc.gridx = 0;
% gbc.gridy = GridBagConstraints.RELATIVE;
% t3 = BorderFactory.createTitledBorder('Run Lists:');
% btn1Panel.setBorder(t3);
% 
% % Array definition for JTable and run list buttons
% headArray = javaArray('java.lang.String',1);
% headArray(1) = java.lang.String('Run Lists');
% listArray = javaArray('java.lang.Object',length(runvals),1);
% btn = cell([length(runvals) 3]);
% callback3 = @(obj,evt)onListSelect(obj,evt);
% for i = 1:length(runvals)
%     listArray(i,1) = java.lang.String(runvals{i});
%     btn{i,1} = JButton(runvals{i});
%     btn{i,2} = handle(btn{i,1},'CallbackProperties');
%     btn{i,3} = 0; % False flag
%     set(btn{i,2},'MouseClickedCallback', callback3);
%     btn{i,1}.setEnabled(0);
%     btn1Panel.add(btn{i,1}, gbc);
% end
% 
% % Set-up reset button
% resetBtn = JButton('Reset');
% rbh = handle(resetBtn,'CallbackProperties');
% callback2 = @(obj,evt)onReset(obj,evt);
% set(rbh,'MouseClickedCallback', callback2);

% % Define JTable
% table = JTable();
% dataModel = DefaultTableModel(listArray,headArray);
% table.setModel(dataModel);
% table.setEnabled(0);
% 
% % Set-up second right panel
% btn2Panel = JPanel(GridBagLayout());
% t4 = BorderFactory.createTitledBorder('Order:');
% btn2Panel.setBorder(t4);
% btn2Panel.add(table,gbc);
% btn2Panel.add(resetBtn,gbc);
% 
% % Set-up entire right pane
% right = JPanel(GridLayout(1,3));
% right.setMinimumSize(Dimension(250,425));
% right.setPreferredSize(Dimension(250,425));
% right.add(btn1Panel);
% right.add(btn2Panel);

% Set-up confirm button
confirm = JButton('Confirm');
cbh = handle(confirm,'CallbackProperties');
callback1 = @(obj,evt)onConfirm(obj,evt);
set(cbh,'MouseClickedCallback', callback1);

% Set-up bottom pane
bot = JPanel();
bot.setMinimumSize(Dimension(400,75));
bot.setPreferredSize(Dimension(400,75));
bot.add(confirm);

% Split left and right
% splitpane1 = JSplitPane(JSplitPane.HORIZONTAL_SPLIT,left,right);
% splitpane1.setEnabled(false);

% Split top and bottom
splitpane2 = JSplitPane(JSplitPane.VERTICAL_SPLIT,left,bot);
splitpane2.setEnabled(false);

frame.add(splitpane2);

frame.setResizable(0);
frame.setVisible(1);

%     function onListSelect(obj,evt) % When a run list button is pressed
%         btn_txt = obj.get.Label();
%         btn_index = strcmp(runvals,btn_txt);
%         if btn{btn_index,3} % Only if flag is set true
%             btn{btn_index,1}.setEnabled(0);
%             list_index = find(cellfun(@isempty,cell(listArray)),1);
%             listArray(list_index,1) = java.lang.String(btn_txt); % Modify list array
%             dataModel.addRow(java.lang.String(btn_txt)); % Add row
%             btn{btn_index,3} = 0; % Set false flag
%         else
%         end
%     end

%     function onReset(obj,evt) % Whem the reset button is pressed
%         dataModel.setRowCount(0); % Clear table
%         listArray = [];
%         listArray = javaArray('java.lang.Object',length(runvals),1); % Re-initialize listArray
%         for j = 1:length(btn); % Reset run list buttons and set flags true
%             btn{j,1}.setEnabled(1);
%             btn{j,3} = 1;
%         end
%     end

    function onConfirm(obj,evt) % When confirm button is pressed
        sid = tf1.getText();
        run = tf2.getText();
        interval = tf3.getText();
        selectedModel1 = group1.getSelection();
        trig = selectedModel1.getActionCommand();
%         listout = cell(listArray);
        
        if isempty(char(sid))
            javax.swing.JOptionPane.showMessageDialog(frame,'Subject ID is empty!','Subject ID check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif isempty(char(run))
            javax.swing.JOptionPane.showMessageDialog(frame,'Number of runs is empty!','Number of runs check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif isnan(str2double(char(run)))
            javax.swing.JOptionPane.showMessageDialog(frame,'Invalid number of runs entry!','Number of runs check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif isempty(char(interval)) % Check for empty SID
            javax.swing.JOptionPane.showMessageDialog(frame,'Interval is empty!','Interval check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif isnan(str2double(char(interval)))
            javax.swing.JOptionPane.showMessageDialog(frame,'Invalid interval entry!','Number of runs check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
%         elseif any(cellfun(@isempty,listout)) % Check for empty entries in order list
%             javax.swing.JOptionPane.showMessageDialog(frame,'There are unused orders!','Order list check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        else
            
%             % Parameter confirmation
%             s = [];
%             for k = 1:length(listout)
%                 s = [s 'Run ' int2str(k) ': ' listout{k} '\n'];
%             end
            
            infostring = sprintf(['Subject ID: ' char(sid) ...
                '\nNumber of runs: ' char(run) ...
                '\nInterval: ' char(interval) ...
                '\nTrigger: ' char(trig) ...
                '\n\nIs this correct?']);
%                 '\nOrder: \n' s(1:end-2) ...
            result = javax.swing.JOptionPane.showConfirmDialog(frame,infostring,'Confirm parameters',javax.swing.JOptionPane.YES_NO_OPTION);
            
            % Record data and close
            run = str2double(char(run));
            interval = str2double(char(interval));
            if result==javax.swing.JOptionPane.YES_OPTION
                switch char(trig)
                    case 'Yes'
                        trig = 1;
                    case 'No'
                        trig = 0;
                end
                setappdata(frame,'UserData',{char(sid),run,interval,trig});
                frame.dispose();
            else
            end
        end
    end

    function onClose(obj,evt) % When close button on frame is pressed
        setappdata(frame,'UserData',[]);
        frame.setVisible(0);
        frame.dispose();
    end
end