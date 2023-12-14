classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Menus               matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        Left                matlab.ui.container.Panel
        Tree                matlab.ui.container.Tree
        RootNode            matlab.ui.container.TreeNode
        histequal           matlab.ui.container.TreeNode
        Space               matlab.ui.container.TreeNode
        MidFilt             matlab.ui.container.TreeNode
        Rebuild             matlab.ui.container.TreeNode
        Node_6              matlab.ui.container.TreeNode
        Center              matlab.ui.container.Panel
        PreviewOnOffSwitch  matlab.ui.control.ToggleSwitch
        Switch_2Label       matlab.ui.control.Label
        PreviewModeSwitch   matlab.ui.control.Switch
        Label               matlab.ui.control.Label
        MainGraph           matlab.ui.control.UIAxes
        Right               matlab.ui.container.Panel
        Panel               matlab.ui.container.Panel
        TabGroup            matlab.ui.container.TabGroup
        Tab_4               matlab.ui.container.Tab
        h                   matlab.ui.control.Spinner
        Label_3             matlab.ui.control.Label
        w                   matlab.ui.control.Spinner
        Label_2             matlab.ui.control.Label
        Tab_5               matlab.ui.container.Tab
        EditField           matlab.ui.control.EditField
        Label_4             matlab.ui.control.Label
        Tab_6               matlab.ui.container.Tab
        Tab_7               matlab.ui.container.Tab
        InfoTabs            matlab.ui.container.TabGroup
        Hist                matlab.ui.container.Tab
        HistSeperateSwitch  matlab.ui.control.Switch
        SwitchLabel         matlab.ui.control.Label
        HistAxes            matlab.ui.control.UIAxes
        Ocil                matlab.ui.container.Tab
        RGBSwitch_2         matlab.ui.control.Switch
        RGBSwitch_2Label    matlab.ui.control.Label
        OcilAx_2            matlab.ui.control.UIAxes
        OcilAx              matlab.ui.control.UIAxes
        Tab_3               matlab.ui.container.Tab
        Files               matlab.ui.container.Menu
        Open                matlab.ui.container.Menu
        Save                matlab.ui.container.Menu
        SaveAnother         matlab.ui.container.Menu
        Close               matlab.ui.container.Menu
        Edit                matlab.ui.container.Menu
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
                
                    histogram(app.HistAxes,R,'BinMethod','integers','FaceColor','r','EdgeAlpha',0,'FaceAlpha',0.7)
                    %hold on
                    histogram(app.HistAxes,G,'BinMethod','integers','FaceColor','g','EdgeAlpha',0,'FaceAlpha',0.7)
                    histogram(app.HistAxes,B,'BinMethod','integers','FaceColor','b','EdgeAlpha',0,'FaceAlpha',0.7)
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

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            selectedNodes = app.Tree.SelectedNodes;
            app.Panel.Title = selectedNodes.Text;
            switch (selectedNodes.Text)
                case '直方图均衡化'
                    app.PreviewGraphArray = histeq(app.MainGraphArray);
                    %imshow(app.PreviewGraphArray)
                    app.FlushMainGraph();
                case '中值滤波'
                    %h = uicontrol(app.Panel,"Style","edit");
                    % 创建提示词
                    text1 = uilabel(app.Panel, 'Position', [20 120 20 20], 'Text', '长');
                    text2 = uilabel(app.Panel, 'Position', [20 80 20 20], 'Text', '宽');
                    
                    % 创建输入框
                    h = uieditfield(app.Panel, "numeric", 'Position', [35 120 100 20]);
                    w = uieditfield(app.Panel, "numeric", 'Position', [35 80 100 20]);

                    %h = uieditfield(app.Panel,"numeric");
                    %w = uieditfield(app.Panel,"numeric");
                    
                    button = uibutton(app.Panel, 'Position', [20 150 135 30], 'Text', '确定');
                    
                    
                    
                    h.Value=5; w.Value=5;
                    
                    %w = uicontrol(app.Panel,"Style","edit");
                    
                    
                    %if (app.GraphChannel == 3)
                        app.PreviewGraphArray(:,:,1) = medfilt2(app.MainGraphArray(:,:,1),[h.Value w.Value]);
                        app.PreviewGraphArray(:,:,2) = medfilt2(app.MainGraphArray(:,:,2),[h.Value w.Value]);
                        app.PreviewGraphArray(:,:,3) = medfilt2(app.MainGraphArray(:,:,3),[h.Value w.Value]);
                        imshow(app.PreviewGraphArray)
                    %else
                    %    app.PreviewGraphArray = medfilt2(app.MainGraphArray, [h w]);
                    %end
                otherwise
                    
                    app.Panel
            end
            app.FlushMainGraph();
            
        end

        % Menu selected function: Open
        function OpenFile(app, event)
            % MainGraphArray = uiopen('*.jpg');
            
            app.ToOpen();
            
            
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

        % Value changed function: HistSeperateSwitch
        function HistSeperateSwitchValueChanged(app, event)
            value = app.HistSeperateSwitch.Value;
            app.FlushHist();
        end

        % Value changed function: RGBSwitch_2
        function RGBSwitch_2ValueChanged(app, event)
            value = app.RGBSwitch_2.Value;
            app.FlushOcil();
            app.FlushOcilSlow();
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
            app.Tree.Position = [35 362 150 300];

            % Create RootNode
            app.RootNode = uitreenode(app.Tree);
            app.RootNode.Text = 'Root';

            % Create histequal
            app.histequal = uitreenode(app.RootNode);
            app.histequal.Tag = 'hsteq';
            app.histequal.Text = '直方图均衡化';

            % Create Space
            app.Space = uitreenode(app.RootNode);
            app.Space.Text = '空间滤波';

            % Create MidFilt
            app.MidFilt = uitreenode(app.Space);
            app.MidFilt.Text = '中值滤波';

            % Create Rebuild
            app.Rebuild = uitreenode(app.RootNode);
            app.Rebuild.Text = '复原和重建';

            % Create Node_6
            app.Node_6 = uitreenode(app.Rebuild);
            app.Node_6.Text = 'Node';

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
            app.Switch_2Label.Position = [113 245 29 22];
            app.Switch_2Label.Text = '预览';

            % Create PreviewOnOffSwitch
            app.PreviewOnOffSwitch = uiswitch(app.Center, 'toggle');
            app.PreviewOnOffSwitch.ValueChangedFcn = createCallbackFcn(app, @PreviewOnOffSwitchValueChanged, true);
            app.PreviewOnOffSwitch.Position = [117 286 20 45];
            app.PreviewOnOffSwitch.Value = 'On';

            % Create Right
            app.Right = uipanel(app.GridLayout);
            app.Right.ForegroundColor = [0.902 0.902 0.902];
            app.Right.Layout.Row = 1;
            app.Right.Layout.Column = 3;
            app.Right.Scrollable = 'on';

            % Create InfoTabs
            app.InfoTabs = uitabgroup(app.Right);
            app.InfoTabs.Position = [6 88 292 412];

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
            app.HistAxes.Position = [1 224 290 164];

            % Create SwitchLabel
            app.SwitchLabel = uilabel(app.Hist);
            app.SwitchLabel.HorizontalAlignment = 'center';
            app.SwitchLabel.Position = [32 183 53 22];
            app.SwitchLabel.Text = '通道分离';

            % Create HistSeperateSwitch
            app.HistSeperateSwitch = uiswitch(app.Hist, 'slider');
            app.HistSeperateSwitch.Items = {'Off', '分离'};
            app.HistSeperateSwitch.ValueChangedFcn = createCallbackFcn(app, @HistSeperateSwitchValueChanged, true);
            app.HistSeperateSwitch.Position = [41 202 29 13];

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
            app.OcilAx.Position = [1 215 290 164];

            % Create OcilAx_2
            app.OcilAx_2 = uiaxes(app.Ocil);
            title(app.OcilAx_2, '示波器(慢速)')
            xlabel(app.OcilAx_2, 'X')
            app.OcilAx_2.AmbientLightColor = [0 0 0];
            app.OcilAx_2.LineWidth = 0.1;
            app.OcilAx_2.Color = [0 0 0];
            app.OcilAx_2.ClippingStyle = 'rectangle';
            app.OcilAx_2.Box = 'on';
            app.OcilAx_2.Position = [1 1 290 164];

            % Create RGBSwitch_2Label
            app.RGBSwitch_2Label = uilabel(app.Ocil);
            app.RGBSwitch_2Label.HorizontalAlignment = 'center';
            app.RGBSwitch_2Label.Position = [18 120 56 22];
            app.RGBSwitch_2Label.Text = 'RGB分离';

            % Create RGBSwitch_2
            app.RGBSwitch_2 = uiswitch(app.Ocil, 'slider');
            app.RGBSwitch_2.Items = {'Off', '分离'};
            app.RGBSwitch_2.ValueChangedFcn = createCallbackFcn(app, @RGBSwitch_2ValueChanged, true);
            app.RGBSwitch_2.Position = [42 178 29 13];

            % Create Tab_3
            app.Tab_3 = uitab(app.InfoTabs);
            app.Tab_3.Title = 'Tab';

            % Create Panel
            app.Panel = uipanel(app.Right);
            app.Panel.Title = 'Panel';
            app.Panel.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.Panel.Position = [6 507 292 221];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.Panel);
            app.TabGroup.Position = [1 -8 291 183];

            % Create Tab_4
            app.Tab_4 = uitab(app.TabGroup);
            app.Tab_4.Title = '中值滤波区域';

            % Create Label_2
            app.Label_2 = uilabel(app.Tab_4);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [40 117 25 22];
            app.Label_2.Text = '长';

            % Create w
            app.w = uispinner(app.Tab_4);
            app.w.Position = [80 117 100 22];

            % Create Label_3
            app.Label_3 = uilabel(app.Tab_4);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [41 83 25 22];
            app.Label_3.Text = '宽';

            % Create h
            app.h = uispinner(app.Tab_4);
            app.h.Position = [81 83 100 22];

            % Create Tab_5
            app.Tab_5 = uitab(app.TabGroup);
            app.Tab_5.Title = '卷积核滤波';

            % Create Label_4
            app.Label_4 = uilabel(app.Tab_5);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [42 117 25 22];
            app.Label_4.Text = '核';

            % Create EditField
            app.EditField = uieditfield(app.Tab_5, 'text');
            app.EditField.Position = [81 117 170 22];
            app.EditField.Value = '[1 1 1; 1 1 1; 1 1 1]';

            % Create Tab_6
            app.Tab_6 = uitab(app.TabGroup);
            app.Tab_6.Title = '频率域滤波';

            % Create Tab_7
            app.Tab_7 = uitab(app.TabGroup);
            app.Tab_7.Title = '逆滤波';

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