classdef CFilterResponse < handle       
    
    % member variables
    properties (SetAccess = private)
        Responses_
        numScales_
        numParts_ = 18;
    end        
    properties % Nonflip / Flip
        root, rootF
        head, headF
        f1, f1F
        s1, s1F
        gr, grF
        s2, s2F
        a1, a1F
        a2, a2F
        f2, f2F
    end
    
    % member function
    methods
        % constructor
        function CFR = CFilterResponse(response)
            CFR.Responses_ = response;
            CFR.numScales_ = size(response, 2);
            CellPartCollection = cell(1, CFR.numParts_);
            
            % save responses among part and scale: CellPartCollection{partIdx}{scale}
            for partIdx = 1:size(CellPartCollection, 2)
                CellPartCollection{partIdx} = cell(1, CFR.numScales_);
                for scale = 1:CFR.numScales_
                    CellPartCollection{partIdx}{scale} = CFR.Responses_{scale}{partIdx};
                end
            end
            
            % save parts as member properties(=variables)
            CFR.root = CellPartCollection{1}; CFR.rootF = CellPartCollection{2};
            CFR.head = CellPartCollection{3}; CFR.headF = CellPartCollection{4};            
            CFR.f1 = CellPartCollection{5};   CFR.f1F = CellPartCollection{6};
            CFR.s1 = CellPartCollection{7};   CFR.s1F = CellPartCollection{8};
            CFR.gr = CellPartCollection{9};   CFR.grF = CellPartCollection{10};
            CFR.s2 = CellPartCollection{11};  CFR.s2F = CellPartCollection{12};
            CFR.a1 = CellPartCollection{13};  CFR.a1F = CellPartCollection{14};
            CFR.a2 = CellPartCollection{15};  CFR.a2F = CellPartCollection{16};
            CFR.f2 = CellPartCollection{17};  CFR.f2F = CellPartCollection{18};
        end
        
        % setter
        function SetPartResponse(CFR, partName, scale, doFlip, response)
            if strcmp(partName, 'root')
                if doFlip, CFR.rootF{scale} = response;
                else       CFR.root{scale} = response; end
            elseif strcmp(partName, 'head')
                if doFlip, CFR.headF{scale} = response;
                else       CFR.head{scale} = response; end
            elseif strcmp(partName, 'arm1')
                if doFlip, CFR.a1F{scale} = response;
                else       CFR.a1{scale} = response; end
            elseif strcmp(partName, 'arm2')
                if doFlip, CFR.a2F{scale} = response;
                else       CFR.a2{scale} = response; end
            elseif strcmp(partName, 'shoulder1')
                if doFlip, CFR.s1F{scale} = response;
                else       CFR.s1{scale} = response; end
            elseif strcmp(partName, 'shoulder2')
                if doFlip, CFR.s2F{scale} = response;
                else       CFR.s2{scale} = response; end
            elseif strcmp(partName, 'groin')
                if doFlip, CFR.grF{scale} = response;
                else       CFR.gr{scale} = response; end
            elseif strcmp(partName, 'foot1')
                if doFlip, CFR.f1F{scale} = response;
                else       CFR.f1{scale} = response; end
            elseif strcmp(partName, 'foot2')
                if doFlip, CFR.f2F{scale} = response;
                else       CFR.f2{scale} = response; end
            else
                disp('**************************************************');
                disp('* WRONG PART NAME!! please check the part name   *');
                disp('* Avaliable part names are...                    *');
                disp('* root, head, arm1, arm2, shoulder1, shoulder2,  *');
                disp('* groin, foot1, foot2                            *');
                disp('**************************************************');
            end
        end
        
        % getter
        function response = GetPartResponse(CFR, partName, scale, doFlip)
            if strcmp(partName, 'root')
                if doFlip, response = CFR.rootF{scale};
                else       response = CFR.root{scale}; end
            elseif strcmp(partName, 'head')
                if doFlip, response = CFR.headF{scale};
                else       response = CFR.head{scale}; end
            elseif strcmp(partName, 'arm1')
                if doFlip, response = CFR.a1F{scale};
                else       response = CFR.a1{scale}; end
            elseif strcmp(partName, 'arm2')
                if doFlip, response = CFR.a2F{scale};
                else       response = CFR.a2{scale}; end
            elseif strcmp(partName, 'shoulder1')
                if doFlip, response = CFR.s1F{scale};
                else       response = CFR.s1{scale}; end
            elseif strcmp(partName, 'shoulder2')
                if doFlip, response = CFR.s2F{scale};
                else       response = CFR.s2{scale}; end
            elseif strcmp(partName, 'groin')
                if doFlip, response = CFR.grF{scale};
                else       response = CFR.gr{scale}; end
            elseif strcmp(partName, 'foot1')
                if doFlip, response = CFR.f1F{scale};
                else       response = CFR.f1{scale}; end
            elseif strcmp(partName, 'foot2')
                if doFlip, response = CFR.f2F{scale};
                else       response = CFR.f2{scale}; end
            else
                disp('**************************************************');
                disp('* WRONG PART NAME!! please check the part name   *');
                disp('* Avaliable part names are...                    *');
                disp('* root, head, arm1, arm2, shoulder1, shoulder2,  *');
                disp('* groin, foot1, foot2                            *');
                disp('**************************************************');
            end
        end
        
        % show filter response
        function frshow(CFR, partName, scale, doFlip)
            curResponse = GetPartResponse(CFR, partName, scale, doFlip);
            imshow(curResponse, 'Border', 'Tight');
        end
    end
end
