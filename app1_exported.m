classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Menus                   matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        Left                    matlab.ui.container.Panel
        Tree                    matlab.ui.container.Tree
        RootNode                matlab.ui.container.TreeNode
        Node_8                  matlab.ui.container.TreeNode
        histequal               matlab.ui.container.TreeNode
        SpaceFiltNode           matlab.ui.container.TreeNode
        MedFiltNode             matlab.ui.container.TreeNode
        ConvFiltNode            matlab.ui.container.TreeNode
        FreFiltNode             matlab.ui.container.TreeNode
        Node_9                  matlab.ui.container.TreeNode
        Node_10                 matlab.ui.container.TreeNode
        Rebuild                 matlab.ui.container.TreeNode
        Node_6                  matlab.ui.container.TreeNode
        Node_12                 matlab.ui.container.TreeNode
        Node_13                 matlab.ui.container.TreeNode
        Node_7                  matlab.ui.container.TreeNode
        Node_11                 matlab.ui.container.TreeNode
        Node_14                 matlab.ui.container.TreeNode
        Node_15                 matlab.ui.container.TreeNode
        Center                  matlab.ui.container.Panel
        PreviewOnOffSwitch      matlab.ui.control.ToggleSwitch
        Switch_2Label           matlab.ui.control.Label
        PreviewModeSwitch       matlab.ui.control.Switch
        Label                   matlab.ui.control.Label
        MainGraph               matlab.ui.control.UIAxes
        Right                   matlab.ui.container.Panel
        ApplyButton             matlab.ui.control.Button
        Panel                   matlab.ui.container.Panel
        InfoTabs                matlab.ui.container.TabGroup
        Hist                    matlab.ui.container.Tab
        HistSeperateSwitch      matlab.ui.control.Switch
        SwitchLabel             matlab.ui.control.Label
        HistAxes                matlab.ui.control.UIAxes
        Ocil                    matlab.ui.container.Tab
        RGBSwitch_2             matlab.ui.control.Switch
        RGBSwitch_2Label        matlab.ui.control.Label
        OcilAx_2                matlab.ui.control.UIAxes
        OcilAx                  matlab.ui.control.UIAxes
        Tab_3                   matlab.ui.container.Tab
        ParaPanel               matlab.ui.container.Panel
        ParaTabGroup            matlab.ui.container.TabGroup
        engray_tab              matlab.ui.container.Tab
        enrgray_tip             matlab.ui.control.Label
        hist_eq_tab             matlab.ui.container.Tab
        Label_5                 matlab.ui.control.Label
        MedFiltTab              matlab.ui.container.Tab
        Medh                    matlab.ui.control.Spinner
        Label_3                 matlab.ui.control.Label
        Medw                    matlab.ui.control.Spinner
        Label_2                 matlab.ui.control.Label
        ConvFiltTab             matlab.ui.container.Tab
        CoreTemplateDropDown    matlab.ui.control.DropDown
        Label_6                 matlab.ui.control.Label
        CoreEditField           matlab.ui.control.EditField
        evalLabel               matlab.ui.control.Label
        reverse_filt            matlab.ui.container.Tab
        Label_8                 matlab.ui.control.Label
        CoreTemplateDropDown_2  matlab.ui.control.DropDown
        Label_7                 matlab.ui.control.Label
        CoreEditField_2         matlab.ui.control.EditField
        evalLabel_2             matlab.ui.control.Label
        fre_filt_tab            matlab.ui.container.Tab
        Spinner                 matlab.ui.control.Spinner
        Label_9                 matlab.ui.control.Label
        Tab_4                   matlab.ui.container.Tab
        Label_11                matlab.ui.control.Label
        motionDeg               matlab.ui.control.Knob
        motionLen               matlab.ui.control.Slider
        Label_10                matlab.ui.control.Label
        Files                   matlab.ui.container.Menu
        Open                    matlab.ui.container.Menu
        Save                    matlab.ui.container.Menu
        SaveAnother             matlab.ui.container.Menu
        Close                   matlab.ui.container.Menu
        Edit                    matlab.ui.container.Menu
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = public)
        MainGraphArray % 主图像数组
        PreviewGraphArray % 预览图像数组
        DisplayGraphArray %
        GraphChannel
        GraphWidth
        GraphHeight
        IsGray
    end
    
    
    
    methods (Access = public)  
        function ToOpen(app)
            %app.MainArray = imread(uiopen());
            [path,filename] = uigetfile( ...
                    {
                        "*.jpg;.*.jpeg;*.jpe;*.jfif;*.png;*.bmp;*.webp;*.hiec;*.hif;*.tif;*.tiff",...
                        '图片文件';
                        
                        '*.jpg,.*.jpeg,*.jpe,*.jfif','JPEG';
                        '*.png',                     'PNG';
                        '*.bmp',                     'bmp';
                        '*.webp',                    'webp';
                        '*.hiec,*.hif',              'HEIC';
                        '*.tif;*.tiff',              'TIFF';
                        '*.*',                       "所有文件";
                    }...
                );
            assert(filename ~= "","没有选择文件");
            
            if(filename == "" || path == "")
                app.MainGraphArray=imread("peppers.png");
            end
            app.MainGraphArray = imread(strcat(filename,path));
            
            if (size(size(app.MainGraphArray)) == 3)
                app.GraphChannel = size(app.MainGraphArray,3);
            else
                app.GraphChannel = 1;
            end
            
            app.IsGray = app.GraphChannel == 1;
            [app.GraphHeight app.GraphWidth ~] = size(app.MainGraphArray);
            app.PreviewGraphArray = app.MainGraphArray;
            app.DisplayGraphArray = app.MainGraphArray;
            app.FlushMainGraph();
            
        end
        
        function FlushMainGraph(app)
            %app.MainGraph.imshow(app.MainGraphArray);
            switch (app.PreviewOnOffSwitch.Value)
                case 'Off'
                    app.DisplayGraphArray = app.MainGraphArray;
                case 'On'
                    switch (app.PreviewModeSwitch.Value)
                        case '左右'
                            size(app.MainGraphArray(:,1:floor(app.GraphWidth/2),:))
                            size(app.PreviewGraphArray(:,floor(app.GraphWidth/2)+1:app.GraphWidth,:))
                            app.DisplayGraphArray = cat(2,...
                                        app.MainGraphArray(:,1:floor(app.GraphWidth/2),:), ...
                                        app.PreviewGraphArray(:,(floor(app.GraphWidth/2)+1):app.GraphWidth, :)...
                                    );
                        case '全部'
                            app.DisplayGraphArray = app.PreviewGraphArray;
                    end
            end
            image(app.MainGraph,app.DisplayGraphArray);
        end
           
        
        function FlushOcilSlow(app)
            
            switch (app.RGBSwitch_2.Value)
                case '分离'
                    cla(app.OcilAx_2);
                    hold(app.OcilAx_2,"on");
                    R = (app.MainGraphArray(:,:,1));
                    G = (app.DisplayGraphArray(:,:,2)); 
                    B = (app.DisplayGraphArray(:,:,3)); 
                    
                    col(1:height(app.DisplayGraphArray),1)=1;
                    idx = col*[1:width(app.DisplayGraphArray)];
                    DOT_SZ = 1;
                    ALPHA_LEVEL = 0.01;
                    
                    sr=scatter(app.OcilAx_2,idx(:),R(:),"red",'.');
                    sr.MarkerEdgeAlpha = ALPHA_LEVEL;
        
                    sg=scatter(app.OcilAx_2,idx(:),G(:),"green",'.');
                    sg.MarkerEdgeAlpha = ALPHA_LEVEL;
                    sb=scatter(app.OcilAx_2,idx(:),B(:),"blue",'.');
                    sb.MarkerEdgeAlpha = ALPHA_LEVEL;
                    app.OcilAx_2.XLim = [1 width(app.DisplayGraphArray)];
                    app.OcilAx_2.YLim = [0 256];
                    app.OcilAx_2.YTick = [0 64 127 192 256];
                case 'Off'
                    cla(app.OcilAx_2);
                    
                    [w,h,chn] = size(app.DisplayGraphArray);
                    W(1:w,1:h) = mean(app.DisplayGraphArray,3);
                    
                    col(1:height(app.DisplayGraphArray),1)=1;
                    idx = (col*[1:width(app.DisplayGraphArray)]);
                    
                    ALPHA_LEVEL = 0.01;
                    sr=scatter(app.OcilAx_2,idx(:),W(:),"white",'.');
                    sr.MarkerEdgeAlpha = ALPHA_LEVEL;
            end % switch rgbswitch_2
            
        end % func flushocilslow
        
        
        function FlushOcil(app)
            cla(app.OcilAx);
            
            app.OcilAx.XLim = [1 width(app.DisplayGraphArray)];
            app.OcilAx.YLim = [0 256];
            app.OcilAx.YTick = [0 64 127 192 256];
            
            R = app.DisplayGraphArray(:,:,1);
            G = app.DisplayGraphArray(:,:,2); 
            B = app.DisplayGraphArray(:,:,3); 
            W = (R+G+B)./3.0;
            
            XR = mean(R,1);
            XG = mean(G,1);
            XB = mean(B,1);
            XW = mean(W,1);
            
            switch app.RGBSwitch_2.Value
                case '分离'
                    
                    plot(app.OcilAx,XR,"Color",'r');
                    hold(app.OcilAx,"on");
                    plot(app.OcilAx,XG,"Color",'g');
                    plot(app.OcilAx,XB,"Color",'b');
                    hold(app.OcilAx,"off");
                case 'Off'
                    plot(app.OcilAx,XW,"Color",'white');
                    
            end
        end %func FlushOcil(app)
        
        
        function FlushHist(app) %%%%%%%%%%%%%%%%%
            
            cla(app.HistAxes);
            
            targGraf = app.PreviewGraphArray;
            if app.PreviewOnOffSwitch.Value == "Off"
                targGraf = app.DisplayGraphArray;
            end
            
            switch app.HistSeperateSwitch.Value
                
                case '分离'
                    hold(app.HistAxes,"on");
                    N = size(targGraf);
                    R = targGraf(:,:,1); 
                    G = targGraf(:,:,2); 
                    B = targGraf(:,:,3); 
                    %[R G B] = double([R G B]);
                  %  plot(app.HistAxes,imhist(R),'MarkerFaceColor','r');
                  %  plot(app.HistAxes,imhist(G),'MarkerFaceColor','g');
                  %  plot(app.HistAxes,imhist(B),'MarkerFaceColor','b');
                
                    histogram(app.HistAxes,R,'BinMethod','integers','FaceColor','r','EdgeAlpha',0,'FaceAlpha',0.5)
                    %hold on
                    histogram(app.HistAxes,G,'BinMethod','integers','FaceColor','g','EdgeAlpha',0,'FaceAlpha',0.5)
                    histogram(app.HistAxes,B,'BinMethod','integers','FaceColor','b','EdgeAlpha',0,'FaceAlpha',0.5)
                    %if() 
                        %app.HistAxes.XLim = [0 255];
                        %app.HistAxes.YLim = [0 1.0];
                    
                    %app.HistAxes.xlabel('RGB value')
                    %app.HistAxes.ylabel('Frequency')
                                        
                    
                    
                    %app.HistAxes = imhist(targGraf);
                    
                case 'Off'
                    histogram(app.HistAxes,im2gray(targGraf),'BinMethod','integers','FaceColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',1)
                    
            end
            hold(app.HistAxes,"off");
        end
        
        
    end
    
    
    
    events (ListenAccess = public)
        mainArrayModified
        preArrayModified
        treeNodeChanged
        paraChanged
        
        
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

                app.MainGraphArray=imread("peppers.png");
                
                 if (size(size(app.MainGraphArray)) == 3)
                app.GraphChannel = size(app.MainGraphArray,3);
            else
                app.GraphChannel = 1;
            end
            
            app.IsGray = app.GraphChannel == 1;
            [app.GraphHeight app.GraphWidth ~] = size(app.MainGraphArray);
            app.PreviewGraphArray = app.MainGraphArray;
            app.DisplayGraphArray = app.MainGraphArray;
            app.FlushMainGraph();
                
                app.DisplayGraphArray=app.MainGraphArray;
                app.PreviewGraphArray=app.MainGraphArray;
                app.FlushMainGraph();
                app.FlushHist();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.Menus.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {729, 729, 729};
                app.GridLayout.ColumnWidth = {'1x'};
                app.Center.Layout.Row = 1;
                app.Center.Layout.Column = 1;
                app.Left.Layout.Row = 2;
                app.Left.Layout.Column = 1;
                app.Right.Layout.Row = 3;
                app.Right.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {729, 729};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.Center.Layout.Row = 1;
                app.Center.Layout.Column = [1,2];
                app.Left.Layout.Row = 2;
                app.Left.Layout.Column = 1;
                app.Right.Layout.Row = 2;
                app.Right.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {229, '1x', 303};
                app.Left.Layout.Row = 1;
                app.Left.Layout.Column = 1;
                app.Center.Layout.Row = 1;
                app.Center.Layout.Column = 2;
                app.Right.Layout.Row = 1;
                app.Right.Layout.Column = 3;
            end
        end

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            selectedNodes = app.Tree.SelectedNodes;
            %app.ParaPanel.Title = selectedNodes.Text;
            switch (selectedNodes.Text)
                case '灰度化'
                    app.PreviewGraphArray = im2gray(app.MainGraphArray);
                    app.FlushMainGraph();
                case '直方图均衡化'
                %空间域滤波
                    app.PreviewGraphArray = histeq(app.MainGraphArray);
                    app.InfoTabs.SelectedTab = app.Hist;
                    %imshow(app.PreviewGraphArray)
                    app.FlushMainGraph();
                case '中值滤波'
                    app.InfoTabs.SelectedTab = app.MedFiltTab;
                    h = app.Medh; w=app.Medw;
                    %h = uicontrol(app.ParaPanel,"Style","edit");
                    % 创建提示词
                    %text1 = uilabel(app.ParaPanel, 'Position', [20 120 20 20], 'Text', '长');
                    %text2 = uilabel(app.ParaPanel, 'Position', [20 80 20 20], 'Text', '宽');
                    
                    % 创建输入框
                   % h = uieditfield(app.ParaPanel, "numeric", 'Position', [35 120 100 20]);
                   % w = uieditfield(app.ParaPanel, "numeric", 'Position', [35 80 100 20]);

                    %h = uieditfield(app.ParaPanel,"numeric");
                    %w = uieditfield(app.ParaPanel,"numeric");
                    
                   % button = uibutton(app.ParaPanel, 'Position', [20 150 135 30], 'Text', '确定');
                    
                    
                    
                   % h.Value=5; w.Value=5;
                    
                    %w = uicontrol(app.ParaPanel,"Style","edit");
                    
                    
                    %if (app.GraphChannel == 3)
                        app.PreviewGraphArray(:,:,1) = medfilt2(app.MainGraphArray(:,:,1),[h.Value w.Value]);
                        app.PreviewGraphArray(:,:,2) = medfilt2(app.MainGraphArray(:,:,2),[h.Value w.Value]);
                        app.PreviewGraphArray(:,:,3) = medfilt2(app.MainGraphArray(:,:,3),[h.Value w.Value]);
                        %imshow(app.PreviewGraphArray)
                    %else
                    %    app.PreviewGraphArray = medfilt2(app.MainGraphArray, [h w]);
                    %end
                    
                case '卷积核滤波'
                    app.ParaTabGroup.SelectedTab = app.ConvFiltTab;
                    '由于危险，放弃使用eval';
                    %coremat = eval(app.CoreEditField.Value);
                    [coremat,tf] = str2num(app.CoreEditField.Value,Evaluation="restricted");
                    %for(i=[1 2 3])
                        app.PreviewGraphArray = conv2(app.MainGraphArray,coremat);
                case '运动模糊退化'
                    app.ParaTabGroup.SelectedTab = app.Tab_4;
                    len = app.motionLen.Value;
                    deg = app.motionDeg.Value;
                    H = fspecial('motion',len,deg);
                    app.PreviewGraphArray = imfilter(app.PreviewGraphArray,H,'replicate');
                    app.FlushMainGraph();
                otherwise
                    
                    app.ParaPanel
            end
            app.FlushMainGraph();
            
        end

        % Menu selected function: Open
        function OpenFile(app, event)
            % MainGraphArray = uiopen('*.jpg');
            
            app.ToOpen();
            
            
        end

        % Value changed function: RGBSwitch_2
        function RGBSwitch_2ValueChanged(app, event)
            value = app.RGBSwitch_2.Value;
            app.FlushOcil();
            app.FlushOcilSlow();
        end

        % Value changed function: HistSeperateSwitch
        function HistSeperateSwitchValueChanged(app, event)
            value = app.HistSeperateSwitch.Value;
            app.FlushHist();
        end

        % Value changed function: PreviewOnOffSwitch
        function PreviewOnOffSwitchValueChanged(app, event)
            value = app.PreviewOnOffSwitch.Value;
            app.FlushMainGraph();
            app.FlushHist();
            app.FlushOcil();
            app.FlushOcilSlow();
        end

        % Value changed function: PreviewModeSwitch
        function PreviewModeSwitchValueChanged(app, event)
            value = app.PreviewModeSwitch.Value;
            app.FlushMainGraph();
            app.FlushHist();
            app.FlushOcil();
            app.FlushOcilSlow();
        end

        % Value changed function: Medw
        function MedwValueChanged(app, event)
            notify(app.Medw,paraChanged,app.Medw.Value);
        end

        % Button pushed function: ApplyButton
        function ApplyButtonPushed(app, event)
            app.MainGraphArray = app.PreviewGraphArray;
        end

        % Value changed function: Medh
        function MedhValueChanged(app, event)
             notify(app.Medh,paraChanged,app.Medh.Value);
            
        end

        % Value changed function: CoreTemplateDropDown
        function CoreTemplateDropDownValueChanged(app, event)
            value = app.CoreTemplateDropDown.Value;
            switch value
                case '矩形均值'
                    app.CoreEditField.Value = "ones(3)";
                case '十字均值'
                    app.CoreEditField.Value = "[0 1 0;1 1 1;0 1 0]";
                case '纵向'
                    app.CoreEditField.Value = "[1;1;1]";
                case '横向'
                    app.CoreEditField.Value = "[1 1 1]";
            end
            
        end

        % Value changed function: motionDeg
        function motionDegValueChanged(app, event)
            value = app.motionDeg.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Menus and hide until all components are created
            app.Menus = uifigure('Visible', 'off');
            app.Menus.AutoResizeChildren = 'off';
            app.Menus.Position = [100 100 1059 729];
            app.Menus.Name = 'MATLAB App';
            app.Menus.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.Menus.Scrollable = 'on';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Menus);
            app.GridLayout.ColumnWidth = {229, '1x', 303};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create Left
            app.Left = uipanel(app.GridLayout);
            app.Left.Layout.Row = 1;
            app.Left.Layout.Column = 1;
            app.Left.Scrollable = 'on';

            % Create Tree
            app.Tree = uitree(app.Left);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @TreeSelectionChanged, true);
            app.Tree.Position = [24 78 184 583];

            % Create RootNode
            app.RootNode = uitreenode(app.Tree);
            app.RootNode.Text = 'Root';

            % Create Node_8
            app.Node_8 = uitreenode(app.RootNode);
            app.Node_8.Text = '灰度化';

            % Create histequal
            app.histequal = uitreenode(app.RootNode);
            app.histequal.Tag = 'hsteq';
            app.histequal.Text = '直方图均衡化';

            % Create SpaceFiltNode
            app.SpaceFiltNode = uitreenode(app.RootNode);
            app.SpaceFiltNode.Text = '空间域滤波';

            % Create MedFiltNode
            app.MedFiltNode = uitreenode(app.SpaceFiltNode);
            app.MedFiltNode.Text = '中值滤波';

            % Create ConvFiltNode
            app.ConvFiltNode = uitreenode(app.SpaceFiltNode);
            app.ConvFiltNode.Text = '卷积核滤波';

            % Create FreFiltNode
            app.FreFiltNode = uitreenode(app.RootNode);
            app.FreFiltNode.Text = '频率域滤波';

            % Create Node_9
            app.Node_9 = uitreenode(app.FreFiltNode);
            app.Node_9.Text = '理想窗';

            % Create Node_10
            app.Node_10 = uitreenode(app.FreFiltNode);
            app.Node_10.Text = '高斯窗';

            % Create Rebuild
            app.Rebuild = uitreenode(app.RootNode);
            app.Rebuild.Text = '复原和重建';

            % Create Node_6
            app.Node_6 = uitreenode(app.Rebuild);
            app.Node_6.Text = '逆滤波';

            % Create Node_12
            app.Node_12 = uitreenode(app.Node_6);
            app.Node_12.Text = '频域逆滤波';

            % Create Node_13
            app.Node_13 = uitreenode(app.Node_6);
            app.Node_13.Text = '时域逆滤波';

            % Create Node_7
            app.Node_7 = uitreenode(app.RootNode);
            app.Node_7.Text = '引入退化';

            % Create Node_11
            app.Node_11 = uitreenode(app.Node_7);
            app.Node_11.Text = '引入噪声';

            % Create Node_14
            app.Node_14 = uitreenode(app.Node_7);
            app.Node_14.Text = '大气湍流退化';

            % Create Node_15
            app.Node_15 = uitreenode(app.Node_7);
            app.Node_15.Text = '运动模糊退化';

            % Create Center
            app.Center = uipanel(app.GridLayout);
            app.Center.Layout.Row = 1;
            app.Center.Layout.Column = 2;

            % Create MainGraph
            app.MainGraph = uiaxes(app.Center);
            app.MainGraph.DataAspectRatio = [1 1 1];
            app.MainGraph.PlotBoxAspectRatio = [1 1 1];
            app.MainGraph.TickLabelInterpreter = 'none';
            app.MainGraph.XLim = [0 Inf];
            app.MainGraph.YLim = [0 Inf];
            app.MainGraph.ZLim = [0 Inf];
            app.MainGraph.XColor = 'none';
            app.MainGraph.XTick = [];
            app.MainGraph.XTickLabel = '';
            app.MainGraph.YColor = 'none';
            app.MainGraph.YTick = [];
            app.MainGraph.YTickLabel = '';
            app.MainGraph.ZColor = 'none';
            app.MainGraph.ZTick = [];
            app.MainGraph.ZTickLabel = '';
            app.MainGraph.Color = [0.902 0.902 0.902];
            app.MainGraph.ClippingStyle = 'rectangle';
            app.MainGraph.FontSize = 12;
            app.MainGraph.Clipping = 'off';
            app.MainGraph.Position = [7 350 515 369];

            % Create Label
            app.Label = uilabel(app.Center);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Position = [370 266 53 22];
            app.Label.Text = '预览模式';

            % Create PreviewModeSwitch
            app.PreviewModeSwitch = uiswitch(app.Center, 'slider');
            app.PreviewModeSwitch.Items = {'左右', '全部'};
            app.PreviewModeSwitch.ValueChangedFcn = createCallbackFcn(app, @PreviewModeSwitchValueChanged, true);
            app.PreviewModeSwitch.Position = [373 303 45 20];
            app.PreviewModeSwitch.Value = '左右';

            % Create Switch_2Label
            app.Switch_2Label = uilabel(app.Center);
            app.Switch_2Label.HorizontalAlignment = 'center';
            app.Switch_2Label.Position = [131 277 29 22];
            app.Switch_2Label.Text = '预览';

            % Create PreviewOnOffSwitch
            app.PreviewOnOffSwitch = uiswitch(app.Center, 'toggle');
            app.PreviewOnOffSwitch.Orientation = 'horizontal';
            app.PreviewOnOffSwitch.ValueChangedFcn = createCallbackFcn(app, @PreviewOnOffSwitchValueChanged, true);
            app.PreviewOnOffSwitch.Position = [124 303 45 20];
            app.PreviewOnOffSwitch.Value = 'On';

            % Create Right
            app.Right = uipanel(app.GridLayout);
            app.Right.ForegroundColor = [0.902 0.902 0.902];
            app.Right.Layout.Row = 1;
            app.Right.Layout.Column = 3;
            app.Right.Scrollable = 'on';

            % Create ParaPanel
            app.ParaPanel = uipanel(app.Right);
            app.ParaPanel.Title = '选项';
            app.ParaPanel.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.ParaPanel.Position = [6 507 292 221];

            % Create ParaTabGroup
            app.ParaTabGroup = uitabgroup(app.ParaPanel);
            app.ParaTabGroup.Position = [0 -2 291 199];

            % Create engray_tab
            app.engray_tab = uitab(app.ParaTabGroup);
            app.engray_tab.Title = '灰度化';

            % Create enrgray_tip
            app.enrgray_tip = uilabel(app.engray_tab);
            app.enrgray_tip.Position = [87 88 113 22];
            app.enrgray_tip.Text = {'没有需要设置的选项'; ''};

            % Create hist_eq_tab
            app.hist_eq_tab = uitab(app.ParaTabGroup);
            app.hist_eq_tab.Title = '直方图均衡化';

            % Create Label_5
            app.Label_5 = uilabel(app.hist_eq_tab);
            app.Label_5.Position = [90 88 113 22];
            app.Label_5.Text = {'没有需要设置的选项'; ''};

            % Create MedFiltTab
            app.MedFiltTab = uitab(app.ParaTabGroup);
            app.MedFiltTab.Title = '中值滤波区域';

            % Create Label_2
            app.Label_2 = uilabel(app.MedFiltTab);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [40 133 25 22];
            app.Label_2.Text = '长';

            % Create Medw
            app.Medw = uispinner(app.MedFiltTab);
            app.Medw.Limits = [0 50];
            app.Medw.ValueChangedFcn = createCallbackFcn(app, @MedwValueChanged, true);
            app.Medw.Position = [80 133 100 22];
            app.Medw.Value = 3;

            % Create Label_3
            app.Label_3 = uilabel(app.MedFiltTab);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [41 99 25 22];
            app.Label_3.Text = '宽';

            % Create Medh
            app.Medh = uispinner(app.MedFiltTab);
            app.Medh.Limits = [0 50];
            app.Medh.ValueChangedFcn = createCallbackFcn(app, @MedhValueChanged, true);
            app.Medh.Position = [81 99 100 22];
            app.Medh.Value = 3;

            % Create ConvFiltTab
            app.ConvFiltTab = uitab(app.ParaTabGroup);
            app.ConvFiltTab.Title = '卷积核滤波';

            % Create evalLabel
            app.evalLabel = uilabel(app.ConvFiltTab);
            app.evalLabel.HorizontalAlignment = 'center';
            app.evalLabel.Position = [23 76 76 46];
            app.evalLabel.Text = {'核'; ''; '使用eval读取'};

            % Create CoreEditField
            app.CoreEditField = uieditfield(app.ConvFiltTab, 'text');
            app.CoreEditField.Position = [100 63 170 71];
            app.CoreEditField.Value = '[1 1 1; 1 1 1; 1 1 1]';

            % Create Label_6
            app.Label_6 = uilabel(app.ConvFiltTab);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [45 135 41 22];
            app.Label_6.Text = '核模板';

            % Create CoreTemplateDropDown
            app.CoreTemplateDropDown = uidropdown(app.ConvFiltTab);
            app.CoreTemplateDropDown.Items = {'矩形均值', '十字均值', '纵向', '横向'};
            app.CoreTemplateDropDown.ValueChangedFcn = createCallbackFcn(app, @CoreTemplateDropDownValueChanged, true);
            app.CoreTemplateDropDown.Position = [101 135 100 22];
            app.CoreTemplateDropDown.Value = '矩形均值';

            % Create reverse_filt
            app.reverse_filt = uitab(app.ParaTabGroup);
            app.reverse_filt.Title = '逆滤波';

            % Create evalLabel_2
            app.evalLabel_2 = uilabel(app.reverse_filt);
            app.evalLabel_2.HorizontalAlignment = 'center';
            app.evalLabel_2.Position = [20 29 76 46];
            app.evalLabel_2.Text = {'核'; ''; '使用eval读取'};

            % Create CoreEditField_2
            app.CoreEditField_2 = uieditfield(app.reverse_filt, 'text');
            app.CoreEditField_2.Position = [97 16 170 71];
            app.CoreEditField_2.Value = '[1 1 1; 1 1 1; 1 1 1]';

            % Create Label_7
            app.Label_7 = uilabel(app.reverse_filt);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [42 88 41 22];
            app.Label_7.Text = '核模板';

            % Create CoreTemplateDropDown_2
            app.CoreTemplateDropDown_2 = uidropdown(app.reverse_filt);
            app.CoreTemplateDropDown_2.Items = {'矩形均值', '十字均值', '纵向', '横向'};
            app.CoreTemplateDropDown_2.Position = [98 88 100 22];
            app.CoreTemplateDropDown_2.Value = '矩形均值';

            % Create Label_8
            app.Label_8 = uilabel(app.reverse_filt);
            app.Label_8.Position = [41 133 137 22];
            app.Label_8.Text = {'频域逆滤波交互实现困难'; ''};

            % Create fre_filt_tab
            app.fre_filt_tab = uitab(app.ParaTabGroup);
            app.fre_filt_tab.Title = '频率域滤波';

            % Create Label_9
            app.Label_9 = uilabel(app.fre_filt_tab);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [51 134 29 22];
            app.Label_9.Text = '半径';

            % Create Spinner
            app.Spinner = uispinner(app.fre_filt_tab);
            app.Spinner.Step = 0.2;
            app.Spinner.Limits = [0 Inf];
            app.Spinner.Position = [95 134 100 22];
            app.Spinner.Value = 2;

            % Create Tab_4
            app.Tab_4 = uitab(app.ParaTabGroup);
            app.Tab_4.Title = '运动模糊退化';

            % Create Label_10
            app.Label_10 = uilabel(app.Tab_4);
            app.Label_10.HorizontalAlignment = 'right';
            app.Label_10.Position = [168 -29 53 85];
            app.Label_10.Text = '运动半径';

            % Create motionLen
            app.motionLen = uislider(app.Tab_4);
            app.motionLen.Limits = [0 20];
            app.motionLen.Orientation = 'vertical';
            app.motionLen.Position = [235 9 3 150];
            app.motionLen.Value = 1;

            % Create motionDeg
            app.motionDeg = uiknob(app.Tab_4, 'continuous');
            app.motionDeg.Limits = [-150 150];
            app.motionDeg.MajorTicks = [-150 -120 -90 -60 -30 0 30 60 90 120 150];
            app.motionDeg.ValueChangedFcn = createCallbackFcn(app, @motionDegValueChanged, true);
            app.motionDeg.MinorTicks = [-150 -135 -120 -105 -90 -75 -60 -45 -30 -15 0 15 30 45 60 75 90 105 120 135 150];
            app.motionDeg.FontSize = 8;
            app.motionDeg.Position = [42 30 105 105];

            % Create Label_11
            app.Label_11 = uilabel(app.Tab_4);
            app.Label_11.HorizontalAlignment = 'center';
            app.Label_11.Position = [81 71 29 22];
            app.Label_11.Text = {'角度'; ''};

            % Create Panel
            app.Panel = uipanel(app.Right);
            app.Panel.Title = '信息';
            app.Panel.Position = [8 19 288 434];

            % Create InfoTabs
            app.InfoTabs = uitabgroup(app.Panel);
            app.InfoTabs.Position = [0 44 281 361];

            % Create Hist
            app.Hist = uitab(app.InfoTabs);
            app.Hist.Title = '直方图';

            % Create HistAxes
            app.HistAxes = uiaxes(app.Hist);
            app.HistAxes.Toolbar.Visible = 'off';
            app.HistAxes.Layer = 'top';
            app.HistAxes.XTick = [0 0.25 0.5 0.75 1];
            app.HistAxes.YTick = [0 0.25 0.5 0.75 1];
            app.HistAxes.Color = [0.149 0.149 0.149];
            app.HistAxes.XGrid = 'on';
            app.HistAxes.YGrid = 'on';
            app.HistAxes.Position = [1 155 272 182];

            % Create SwitchLabel
            app.SwitchLabel = uilabel(app.Hist);
            app.SwitchLabel.HorizontalAlignment = 'center';
            app.SwitchLabel.Position = [32 132 53 22];
            app.SwitchLabel.Text = '通道分离';

            % Create HistSeperateSwitch
            app.HistSeperateSwitch = uiswitch(app.Hist, 'slider');
            app.HistSeperateSwitch.Items = {'Off', '分离'};
            app.HistSeperateSwitch.ValueChangedFcn = createCallbackFcn(app, @HistSeperateSwitchValueChanged, true);
            app.HistSeperateSwitch.Position = [41 151 29 13];

            % Create Ocil
            app.Ocil = uitab(app.InfoTabs);
            app.Ocil.Title = '示波器';

            % Create OcilAx
            app.OcilAx = uiaxes(app.Ocil);
            title(app.OcilAx, '示波器')
            xlabel(app.OcilAx, 'X')
            app.OcilAx.AmbientLightColor = [0 0 0];
            app.OcilAx.LineWidth = 0.1;
            app.OcilAx.Color = [0 0 0];
            app.OcilAx.ClippingStyle = 'rectangle';
            app.OcilAx.Box = 'on';
            app.OcilAx.Position = [-1 164 290 164];

            % Create OcilAx_2
            app.OcilAx_2 = uiaxes(app.Ocil);
            title(app.OcilAx_2, '示波器(慢速)')
            xlabel(app.OcilAx_2, 'X')
            app.OcilAx_2.AmbientLightColor = [0 0 0];
            app.OcilAx_2.LineWidth = 0.1;
            app.OcilAx_2.Color = [0 0 0];
            app.OcilAx_2.ClippingStyle = 'rectangle';
            app.OcilAx_2.Box = 'on';
            app.OcilAx_2.Position = [-2 -42 290 164];

            % Create RGBSwitch_2Label
            app.RGBSwitch_2Label = uilabel(app.Ocil);
            app.RGBSwitch_2Label.HorizontalAlignment = 'center';
            app.RGBSwitch_2Label.Position = [40 121 56 22];
            app.RGBSwitch_2Label.Text = 'RGB分离';

            % Create RGBSwitch_2
            app.RGBSwitch_2 = uiswitch(app.Ocil, 'slider');
            app.RGBSwitch_2.Items = {'Off', '分离'};
            app.RGBSwitch_2.ValueChangedFcn = createCallbackFcn(app, @RGBSwitch_2ValueChanged, true);
            app.RGBSwitch_2.Position = [52 149 29 13];

            % Create Tab_3
            app.Tab_3 = uitab(app.InfoTabs);
            app.Tab_3.Title = 'Tab';

            % Create ApplyButton
            app.ApplyButton = uibutton(app.Right, 'push');
            app.ApplyButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyButtonPushed, true);
            app.ApplyButton.Position = [13 469 100 24];
            app.ApplyButton.Text = '应用更改';

            % Create Files
            app.Files = uimenu(app.Menus);
            app.Files.Text = '文件';

            % Create Open
            app.Open = uimenu(app.Files);
            app.Open.MenuSelectedFcn = createCallbackFcn(app, @OpenFile, true);
            app.Open.Text = '打开';

            % Create Save
            app.Save = uimenu(app.Files);
            app.Save.Text = '保存';

            % Create SaveAnother
            app.SaveAnother = uimenu(app.Files);
            app.SaveAnother.Text = '另存为';

            % Create Close
            app.Close = uimenu(app.Files);
            app.Close.Text = '关闭';

            % Create Edit
            app.Edit = uimenu(app.Menus);
            app.Edit.Text = '编辑';

            % Show the figure after all components are created
            app.Menus.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.Menus)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.Menus)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Menus)
        end
    end
end