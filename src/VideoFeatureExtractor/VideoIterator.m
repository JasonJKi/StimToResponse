classdef VideoIterator < handle
   
    properties
        feature
        
        name
        param
        paramLabel
        method
        methodName
        numFeatures
        numFrames
        outputLabel
        
        data
        isPooling = false;
        kernelSize;
        thisPoolWindowIndx
    end

    
    properties (Access = private, Hidden = true)
        frameIndex = 1
        featureFieldNames
        indexer
    end
        
    methods
        function feature = get(this)
            feature = this.feature;
        end

        function this = VideoIterator(feature, numFrames)
            this.feature = feature;
            this.name = feature.NAME;
            this.param = feature.param;
            this.numFeatures = feature.numOutputs;
            this.paramLabel = feature.paramLabel;
            this.numFrames = numFrames;
            this.method = feature.method;
            this.methodName = feature.methodName;
            this.outputLabel = feature.outputLabel;

            reset(this)
        end
        
        function init(this, frame)
            [height, width, numFeatures] = size(frame);
            if this.isPooling
                kernel = this.kernelSize;
                this.thisPoolWindowIndx = poolIndex(height,width,kernel);
                [height, width] = poolSize(height, width, kernel);
            end
            this.data = this.allocateOutputMemory(this.numFrames, height, width, numFeatures);
            this.indexer = this.createIndexer(this.data);
        end
        
        function addFrame(this, frame)
            if this.frameIndex == 1
                init(this, frame)
            end    
            
            iFrame = this.frameIndex;
            
            if this.isPooling
                frame = pooling(frame, this.kernelSize, @max, this.thisPoolWindowIndx);
            end
            
            this.data(iFrame, this.indexer{:}) = frame;
            
            this.frameIndex = iFrame + 1;
        end
        
        function reset(this)
            this.frameIndex = 1;
        end
        
        function preview(this)
            figure
            for i = 1:this.numFrames
                for ii = 1:this.numFeatures
                    frame = squeeze(this.data(:,:,ii,i));
                    subplot(2,2,ii)
                    imagesc(frame)
                    pause(.0001)
                end
            end
            close
        end
        
    end
    
    methods (Static = true)
        
        function output = allocateOutputMemory(numFrames, height, width, numFeatures)
                output = zeros(numFrames, height, width, numFeatures, 'single');
        end
    
       function colons = createIndexer(video)
           numDims = numel(size(video));
           colons = repmat({':'},1,numDims-1); 
       end
           
        
    end
end