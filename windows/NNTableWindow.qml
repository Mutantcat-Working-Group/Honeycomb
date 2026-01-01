import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: nnTableWindow
    width: 1150
    height: 700
    minimumWidth: 1150
    minimumHeight: 700
    title: I18n.t("toolNNTable") || "NN对照表"
    flags: Qt.Window
    modality: Qt.NonModal
    
    // NN层分类数据
    property var nnCategories: [
        "全部",
        "容器 Containers",
        "卷积层 Convolution",
        "池化层 Pooling",
        "填充层 Padding",
        "激活函数 Activation",
        "归一化层 Normalization",
        "循环层 Recurrent",
        "Transformer层",
        "线性层 Linear",
        "Dropout层",
        "稀疏层 Sparse",
        "距离函数 Distance",
        "损失函数 Loss",
        "视觉层 Vision"
    ]
    
    // NN层数据
    property var nnData: [
        // 容器 Containers
        { name: "Module", category: "容器 Containers", desc: "所有神经网络模块的基类", usage: "class MyModel(nn.Module):" },
        { name: "Sequential", category: "容器 Containers", desc: "顺序容器，按添加顺序执行模块", usage: "nn.Sequential(nn.Linear(10, 20), nn.ReLU())" },
        { name: "ModuleList", category: "容器 Containers", desc: "以列表形式保存子模块", usage: "nn.ModuleList([nn.Linear(10, 10) for i in range(10)])" },
        { name: "ModuleDict", category: "容器 Containers", desc: "以字典形式保存子模块", usage: "nn.ModuleDict({'linear': nn.Linear(10, 10)})" },
        { name: "ParameterList", category: "容器 Containers", desc: "以列表形式保存参数", usage: "nn.ParameterList([nn.Parameter(torch.randn(10, 10))])" },
        { name: "ParameterDict", category: "容器 Containers", desc: "以字典形式保存参数", usage: "nn.ParameterDict({'weight': nn.Parameter(torch.randn(10, 10))})" },
        
        // 卷积层 Convolution
        { name: "Conv1d", category: "卷积层 Convolution", desc: "1D卷积，用于序列数据", usage: "nn.Conv1d(in_channels, out_channels, kernel_size)" },
        { name: "Conv2d", category: "卷积层 Convolution", desc: "2D卷积，用于图像数据", usage: "nn.Conv2d(in_channels, out_channels, kernel_size)" },
        { name: "Conv3d", category: "卷积层 Convolution", desc: "3D卷积，用于视频/体积数据", usage: "nn.Conv3d(in_channels, out_channels, kernel_size)" },
        { name: "ConvTranspose1d", category: "卷积层 Convolution", desc: "1D转置卷积（反卷积）", usage: "nn.ConvTranspose1d(in_channels, out_channels, kernel_size)" },
        { name: "ConvTranspose2d", category: "卷积层 Convolution", desc: "2D转置卷积（反卷积）", usage: "nn.ConvTranspose2d(in_channels, out_channels, kernel_size)" },
        { name: "ConvTranspose3d", category: "卷积层 Convolution", desc: "3D转置卷积（反卷积）", usage: "nn.ConvTranspose3d(in_channels, out_channels, kernel_size)" },
        { name: "LazyConv1d", category: "卷积层 Convolution", desc: "延迟初始化的1D卷积", usage: "nn.LazyConv1d(out_channels, kernel_size)" },
        { name: "LazyConv2d", category: "卷积层 Convolution", desc: "延迟初始化的2D卷积", usage: "nn.LazyConv2d(out_channels, kernel_size)" },
        { name: "LazyConv3d", category: "卷积层 Convolution", desc: "延迟初始化的3D卷积", usage: "nn.LazyConv3d(out_channels, kernel_size)" },
        { name: "Unfold", category: "卷积层 Convolution", desc: "从批量输入张量中提取滑动局部块", usage: "nn.Unfold(kernel_size)" },
        { name: "Fold", category: "卷积层 Convolution", desc: "将滑动局部块数组组合成大张量", usage: "nn.Fold(output_size, kernel_size)" },
        
        // 池化层 Pooling
        { name: "MaxPool1d", category: "池化层 Pooling", desc: "1D最大池化", usage: "nn.MaxPool1d(kernel_size)" },
        { name: "MaxPool2d", category: "池化层 Pooling", desc: "2D最大池化", usage: "nn.MaxPool2d(kernel_size)" },
        { name: "MaxPool3d", category: "池化层 Pooling", desc: "3D最大池化", usage: "nn.MaxPool3d(kernel_size)" },
        { name: "MaxUnpool1d", category: "池化层 Pooling", desc: "1D最大反池化", usage: "nn.MaxUnpool1d(kernel_size)" },
        { name: "MaxUnpool2d", category: "池化层 Pooling", desc: "2D最大反池化", usage: "nn.MaxUnpool2d(kernel_size)" },
        { name: "MaxUnpool3d", category: "池化层 Pooling", desc: "3D最大反池化", usage: "nn.MaxUnpool3d(kernel_size)" },
        { name: "AvgPool1d", category: "池化层 Pooling", desc: "1D平均池化", usage: "nn.AvgPool1d(kernel_size)" },
        { name: "AvgPool2d", category: "池化层 Pooling", desc: "2D平均池化", usage: "nn.AvgPool2d(kernel_size)" },
        { name: "AvgPool3d", category: "池化层 Pooling", desc: "3D平均池化", usage: "nn.AvgPool3d(kernel_size)" },
        { name: "FractionalMaxPool2d", category: "池化层 Pooling", desc: "2D分数最大池化", usage: "nn.FractionalMaxPool2d(kernel_size, output_ratio)" },
        { name: "FractionalMaxPool3d", category: "池化层 Pooling", desc: "3D分数最大池化", usage: "nn.FractionalMaxPool3d(kernel_size, output_ratio)" },
        { name: "LPPool1d", category: "池化层 Pooling", desc: "1D幂平均池化", usage: "nn.LPPool1d(norm_type, kernel_size)" },
        { name: "LPPool2d", category: "池化层 Pooling", desc: "2D幂平均池化", usage: "nn.LPPool2d(norm_type, kernel_size)" },
        { name: "AdaptiveMaxPool1d", category: "池化层 Pooling", desc: "1D自适应最大池化", usage: "nn.AdaptiveMaxPool1d(output_size)" },
        { name: "AdaptiveMaxPool2d", category: "池化层 Pooling", desc: "2D自适应最大池化", usage: "nn.AdaptiveMaxPool2d(output_size)" },
        { name: "AdaptiveMaxPool3d", category: "池化层 Pooling", desc: "3D自适应最大池化", usage: "nn.AdaptiveMaxPool3d(output_size)" },
        { name: "AdaptiveAvgPool1d", category: "池化层 Pooling", desc: "1D自适应平均池化", usage: "nn.AdaptiveAvgPool1d(output_size)" },
        { name: "AdaptiveAvgPool2d", category: "池化层 Pooling", desc: "2D自适应平均池化", usage: "nn.AdaptiveAvgPool2d(output_size)" },
        { name: "AdaptiveAvgPool3d", category: "池化层 Pooling", desc: "3D自适应平均池化", usage: "nn.AdaptiveAvgPool3d(output_size)" },
        
        // 填充层 Padding
        { name: "ReflectionPad1d", category: "填充层 Padding", desc: "1D反射填充", usage: "nn.ReflectionPad1d(padding)" },
        { name: "ReflectionPad2d", category: "填充层 Padding", desc: "2D反射填充", usage: "nn.ReflectionPad2d(padding)" },
        { name: "ReflectionPad3d", category: "填充层 Padding", desc: "3D反射填充", usage: "nn.ReflectionPad3d(padding)" },
        { name: "ReplicationPad1d", category: "填充层 Padding", desc: "1D复制填充", usage: "nn.ReplicationPad1d(padding)" },
        { name: "ReplicationPad2d", category: "填充层 Padding", desc: "2D复制填充", usage: "nn.ReplicationPad2d(padding)" },
        { name: "ReplicationPad3d", category: "填充层 Padding", desc: "3D复制填充", usage: "nn.ReplicationPad3d(padding)" },
        { name: "ZeroPad1d", category: "填充层 Padding", desc: "1D零填充", usage: "nn.ZeroPad1d(padding)" },
        { name: "ZeroPad2d", category: "填充层 Padding", desc: "2D零填充", usage: "nn.ZeroPad2d(padding)" },
        { name: "ZeroPad3d", category: "填充层 Padding", desc: "3D零填充", usage: "nn.ZeroPad3d(padding)" },
        { name: "ConstantPad1d", category: "填充层 Padding", desc: "1D常数填充", usage: "nn.ConstantPad1d(padding, value)" },
        { name: "ConstantPad2d", category: "填充层 Padding", desc: "2D常数填充", usage: "nn.ConstantPad2d(padding, value)" },
        { name: "ConstantPad3d", category: "填充层 Padding", desc: "3D常数填充", usage: "nn.ConstantPad3d(padding, value)" },
        { name: "CircularPad1d", category: "填充层 Padding", desc: "1D循环填充", usage: "nn.CircularPad1d(padding)" },
        { name: "CircularPad2d", category: "填充层 Padding", desc: "2D循环填充", usage: "nn.CircularPad2d(padding)" },
        { name: "CircularPad3d", category: "填充层 Padding", desc: "3D循环填充", usage: "nn.CircularPad3d(padding)" },
        
        // 激活函数 Activation
        { name: "ReLU", category: "激活函数 Activation", desc: "修正线性单元 max(0, x)", usage: "nn.ReLU()" },
        { name: "ReLU6", category: "激活函数 Activation", desc: "ReLU6 min(max(0,x), 6)", usage: "nn.ReLU6()" },
        { name: "LeakyReLU", category: "激活函数 Activation", desc: "带泄漏的ReLU", usage: "nn.LeakyReLU(negative_slope=0.01)" },
        { name: "PReLU", category: "激活函数 Activation", desc: "参数化ReLU", usage: "nn.PReLU(num_parameters=1)" },
        { name: "RReLU", category: "激活函数 Activation", desc: "随机泄漏ReLU", usage: "nn.RReLU(lower=0.125, upper=0.333)" },
        { name: "ELU", category: "激活函数 Activation", desc: "指数线性单元", usage: "nn.ELU(alpha=1.0)" },
        { name: "SELU", category: "激活函数 Activation", desc: "自归一化指数线性单元", usage: "nn.SELU()" },
        { name: "CELU", category: "激活函数 Activation", desc: "连续可微ELU", usage: "nn.CELU(alpha=1.0)" },
        { name: "GELU", category: "激活函数 Activation", desc: "高斯误差线性单元", usage: "nn.GELU()" },
        { name: "Sigmoid", category: "激活函数 Activation", desc: "Sigmoid函数 1/(1+e^-x)", usage: "nn.Sigmoid()" },
        { name: "SiLU", category: "激活函数 Activation", desc: "Sigmoid线性单元 (Swish)", usage: "nn.SiLU()" },
        { name: "Mish", category: "激活函数 Activation", desc: "Mish激活函数", usage: "nn.Mish()" },
        { name: "Tanh", category: "激活函数 Activation", desc: "双曲正切函数", usage: "nn.Tanh()" },
        { name: "Softplus", category: "激活函数 Activation", desc: "Softplus函数 log(1+e^x)", usage: "nn.Softplus(beta=1)" },
        { name: "Softsign", category: "激活函数 Activation", desc: "Softsign函数 x/(1+|x|)", usage: "nn.Softsign()" },
        { name: "Softshrink", category: "激活函数 Activation", desc: "软收缩函数", usage: "nn.Softshrink(lambd=0.5)" },
        { name: "Hardshrink", category: "激活函数 Activation", desc: "硬收缩函数", usage: "nn.Hardshrink(lambd=0.5)" },
        { name: "Hardsigmoid", category: "激活函数 Activation", desc: "硬Sigmoid函数", usage: "nn.Hardsigmoid()" },
        { name: "Hardtanh", category: "激活函数 Activation", desc: "硬Tanh函数", usage: "nn.Hardtanh(min_val=-1, max_val=1)" },
        { name: "Hardswish", category: "激活函数 Activation", desc: "硬Swish函数", usage: "nn.Hardswish()" },
        { name: "LogSigmoid", category: "激活函数 Activation", desc: "LogSigmoid函数", usage: "nn.LogSigmoid()" },
        { name: "Tanhshrink", category: "激活函数 Activation", desc: "Tanhshrink函数 x-tanh(x)", usage: "nn.Tanhshrink()" },
        { name: "Threshold", category: "激活函数 Activation", desc: "阈值函数", usage: "nn.Threshold(threshold, value)" },
        { name: "GLU", category: "激活函数 Activation", desc: "门控线性单元", usage: "nn.GLU(dim=-1)" },
        { name: "Softmax", category: "激活函数 Activation", desc: "Softmax函数", usage: "nn.Softmax(dim=1)" },
        { name: "Softmin", category: "激活函数 Activation", desc: "Softmin函数", usage: "nn.Softmin(dim=1)" },
        { name: "Softmax2d", category: "激活函数 Activation", desc: "2D Softmax", usage: "nn.Softmax2d()" },
        { name: "LogSoftmax", category: "激活函数 Activation", desc: "LogSoftmax函数", usage: "nn.LogSoftmax(dim=1)" },
        { name: "MultiheadAttention", category: "激活函数 Activation", desc: "多头注意力机制", usage: "nn.MultiheadAttention(embed_dim, num_heads)" },
        
        // 归一化层 Normalization
        { name: "BatchNorm1d", category: "归一化层 Normalization", desc: "1D批归一化", usage: "nn.BatchNorm1d(num_features)" },
        { name: "BatchNorm2d", category: "归一化层 Normalization", desc: "2D批归一化", usage: "nn.BatchNorm2d(num_features)" },
        { name: "BatchNorm3d", category: "归一化层 Normalization", desc: "3D批归一化", usage: "nn.BatchNorm3d(num_features)" },
        { name: "GroupNorm", category: "归一化层 Normalization", desc: "组归一化", usage: "nn.GroupNorm(num_groups, num_channels)" },
        { name: "LayerNorm", category: "归一化层 Normalization", desc: "层归一化", usage: "nn.LayerNorm(normalized_shape)" },
        { name: "InstanceNorm1d", category: "归一化层 Normalization", desc: "1D实例归一化", usage: "nn.InstanceNorm1d(num_features)" },
        { name: "InstanceNorm2d", category: "归一化层 Normalization", desc: "2D实例归一化", usage: "nn.InstanceNorm2d(num_features)" },
        { name: "InstanceNorm3d", category: "归一化层 Normalization", desc: "3D实例归一化", usage: "nn.InstanceNorm3d(num_features)" },
        { name: "LocalResponseNorm", category: "归一化层 Normalization", desc: "局部响应归一化", usage: "nn.LocalResponseNorm(size)" },
        { name: "RMSNorm", category: "归一化层 Normalization", desc: "均方根归一化", usage: "nn.RMSNorm(normalized_shape)" },
        { name: "SyncBatchNorm", category: "归一化层 Normalization", desc: "跨GPU同步批归一化", usage: "nn.SyncBatchNorm(num_features)" },
        
        // 循环层 Recurrent
        { name: "RNN", category: "循环层 Recurrent", desc: "多层Elman RNN", usage: "nn.RNN(input_size, hidden_size, num_layers)" },
        { name: "LSTM", category: "循环层 Recurrent", desc: "长短期记忆网络", usage: "nn.LSTM(input_size, hidden_size, num_layers)" },
        { name: "GRU", category: "循环层 Recurrent", desc: "门控循环单元", usage: "nn.GRU(input_size, hidden_size, num_layers)" },
        { name: "RNNCell", category: "循环层 Recurrent", desc: "单个RNN单元", usage: "nn.RNNCell(input_size, hidden_size)" },
        { name: "LSTMCell", category: "循环层 Recurrent", desc: "单个LSTM单元", usage: "nn.LSTMCell(input_size, hidden_size)" },
        { name: "GRUCell", category: "循环层 Recurrent", desc: "单个GRU单元", usage: "nn.GRUCell(input_size, hidden_size)" },
        
        // Transformer层
        { name: "Transformer", category: "Transformer层", desc: "基础Transformer模型", usage: "nn.Transformer(d_model, nhead)" },
        { name: "TransformerEncoder", category: "Transformer层", desc: "Transformer编码器", usage: "nn.TransformerEncoder(encoder_layer, num_layers)" },
        { name: "TransformerDecoder", category: "Transformer层", desc: "Transformer解码器", usage: "nn.TransformerDecoder(decoder_layer, num_layers)" },
        { name: "TransformerEncoderLayer", category: "Transformer层", desc: "单层Transformer编码器", usage: "nn.TransformerEncoderLayer(d_model, nhead)" },
        { name: "TransformerDecoderLayer", category: "Transformer层", desc: "单层Transformer解码器", usage: "nn.TransformerDecoderLayer(d_model, nhead)" },
        
        // 线性层 Linear
        { name: "Linear", category: "线性层 Linear", desc: "全连接层 y = xA^T + b", usage: "nn.Linear(in_features, out_features)" },
        { name: "Bilinear", category: "线性层 Linear", desc: "双线性变换层", usage: "nn.Bilinear(in1_features, in2_features, out_features)" },
        { name: "LazyLinear", category: "线性层 Linear", desc: "延迟初始化的全连接层", usage: "nn.LazyLinear(out_features)" },
        { name: "Identity", category: "线性层 Linear", desc: "恒等映射（占位符）", usage: "nn.Identity()" },
        { name: "Flatten", category: "线性层 Linear", desc: "展平层", usage: "nn.Flatten(start_dim=1, end_dim=-1)" },
        { name: "Unflatten", category: "线性层 Linear", desc: "反展平层", usage: "nn.Unflatten(dim, unflattened_size)" },
        
        // Dropout层
        { name: "Dropout", category: "Dropout层", desc: "随机丢弃（以概率p置零）", usage: "nn.Dropout(p=0.5)" },
        { name: "Dropout1d", category: "Dropout层", desc: "1D通道Dropout", usage: "nn.Dropout1d(p=0.5)" },
        { name: "Dropout2d", category: "Dropout层", desc: "2D通道Dropout", usage: "nn.Dropout2d(p=0.5)" },
        { name: "Dropout3d", category: "Dropout层", desc: "3D通道Dropout", usage: "nn.Dropout3d(p=0.5)" },
        { name: "AlphaDropout", category: "Dropout层", desc: "Alpha Dropout（用于SELU）", usage: "nn.AlphaDropout(p=0.5)" },
        { name: "FeatureAlphaDropout", category: "Dropout层", desc: "特征Alpha Dropout", usage: "nn.FeatureAlphaDropout(p=0.5)" },
        
        // 稀疏层 Sparse
        { name: "Embedding", category: "稀疏层 Sparse", desc: "嵌入查找表", usage: "nn.Embedding(num_embeddings, embedding_dim)" },
        { name: "EmbeddingBag", category: "稀疏层 Sparse", desc: "嵌入袋（求和/平均）", usage: "nn.EmbeddingBag(num_embeddings, embedding_dim)" },
        
        // 距离函数 Distance
        { name: "CosineSimilarity", category: "距离函数 Distance", desc: "余弦相似度", usage: "nn.CosineSimilarity(dim=1)" },
        { name: "PairwiseDistance", category: "距离函数 Distance", desc: "成对距离", usage: "nn.PairwiseDistance(p=2)" },
        
        // 损失函数 Loss
        { name: "L1Loss", category: "损失函数 Loss", desc: "L1损失（MAE）", usage: "nn.L1Loss()" },
        { name: "MSELoss", category: "损失函数 Loss", desc: "均方误差损失", usage: "nn.MSELoss()" },
        { name: "CrossEntropyLoss", category: "损失函数 Loss", desc: "交叉熵损失（分类）", usage: "nn.CrossEntropyLoss()" },
        { name: "NLLLoss", category: "损失函数 Loss", desc: "负对数似然损失", usage: "nn.NLLLoss()" },
        { name: "BCELoss", category: "损失函数 Loss", desc: "二元交叉熵损失", usage: "nn.BCELoss()" },
        { name: "BCEWithLogitsLoss", category: "损失函数 Loss", desc: "带Sigmoid的BCE损失", usage: "nn.BCEWithLogitsLoss()" },
        { name: "CTCLoss", category: "损失函数 Loss", desc: "CTC损失（序列）", usage: "nn.CTCLoss()" },
        { name: "KLDivLoss", category: "损失函数 Loss", desc: "KL散度损失", usage: "nn.KLDivLoss()" },
        { name: "HuberLoss", category: "损失函数 Loss", desc: "Huber损失", usage: "nn.HuberLoss(delta=1.0)" },
        { name: "SmoothL1Loss", category: "损失函数 Loss", desc: "平滑L1损失", usage: "nn.SmoothL1Loss()" },
        { name: "PoissonNLLLoss", category: "损失函数 Loss", desc: "泊松NLL损失", usage: "nn.PoissonNLLLoss()" },
        { name: "GaussianNLLLoss", category: "损失函数 Loss", desc: "高斯NLL损失", usage: "nn.GaussianNLLLoss()" },
        { name: "MarginRankingLoss", category: "损失函数 Loss", desc: "边缘排序损失", usage: "nn.MarginRankingLoss(margin=0)" },
        { name: "HingeEmbeddingLoss", category: "损失函数 Loss", desc: "Hinge嵌入损失", usage: "nn.HingeEmbeddingLoss(margin=1.0)" },
        { name: "MultiMarginLoss", category: "损失函数 Loss", desc: "多类Hinge损失", usage: "nn.MultiMarginLoss()" },
        { name: "MultiLabelMarginLoss", category: "损失函数 Loss", desc: "多标签Margin损失", usage: "nn.MultiLabelMarginLoss()" },
        { name: "SoftMarginLoss", category: "损失函数 Loss", desc: "软边缘损失", usage: "nn.SoftMarginLoss()" },
        { name: "MultiLabelSoftMarginLoss", category: "损失函数 Loss", desc: "多标签软边缘损失", usage: "nn.MultiLabelSoftMarginLoss()" },
        { name: "CosineEmbeddingLoss", category: "损失函数 Loss", desc: "余弦嵌入损失", usage: "nn.CosineEmbeddingLoss(margin=0)" },
        { name: "TripletMarginLoss", category: "损失函数 Loss", desc: "三元组损失", usage: "nn.TripletMarginLoss(margin=1.0)" },
        { name: "TripletMarginWithDistanceLoss", category: "损失函数 Loss", desc: "带距离的三元组损失", usage: "nn.TripletMarginWithDistanceLoss()" },
        
        // 视觉层 Vision
        { name: "PixelShuffle", category: "视觉层 Vision", desc: "像素重排（上采样）", usage: "nn.PixelShuffle(upscale_factor)" },
        { name: "PixelUnshuffle", category: "视觉层 Vision", desc: "像素反重排（下采样）", usage: "nn.PixelUnshuffle(downscale_factor)" },
        { name: "Upsample", category: "视觉层 Vision", desc: "上采样层", usage: "nn.Upsample(scale_factor=2, mode='nearest')" },
        { name: "UpsamplingNearest2d", category: "视觉层 Vision", desc: "2D最近邻上采样", usage: "nn.UpsamplingNearest2d(scale_factor=2)" },
        { name: "UpsamplingBilinear2d", category: "视觉层 Vision", desc: "2D双线性上采样", usage: "nn.UpsamplingBilinear2d(scale_factor=2)" },
        { name: "ChannelShuffle", category: "视觉层 Vision", desc: "通道重排", usage: "nn.ChannelShuffle(groups)" }
    ]
    
    // 过滤后的数据
    property var filteredData: nnData
    
    // 当前选中的分类
    property int selectedCategoryIndex: 0
    
    // 当前选中的层（用于显示详情）
    property var selectedLayer: null
    
    // 过滤数据
    function filterData() {
        var searchText = searchInput.text.toLowerCase()
        var category = nnCategories[selectedCategoryIndex]
        
        filteredData = nnData.filter(function(item) {
            var matchCategory = (category === "全部") || (item.category === category)
            var matchSearch = searchText === "" || 
                              item.name.toLowerCase().indexOf(searchText) !== -1 ||
                              item.desc.toLowerCase().indexOf(searchText) !== -1 ||
                              item.usage.toLowerCase().indexOf(searchText) !== -1
            return matchCategory && matchSearch
        })
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardHelper.text = text
        clipboardHelper.selectAll()
        clipboardHelper.copy()
    }
    
    TextEdit {
        id: clipboardHelper
        visible: false
        selectByMouse: true
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolNNTable") || "NN对照表"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolNNTableDesc") || "PyTorch神经网络层速查表"
                    font.pixelSize: 13
                    color: "#666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 搜索和分类区域
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                // 搜索框
                TextField {
                    id: searchInput
                    Layout.preferredWidth: 300
                    placeholderText: "搜索层名称、描述..."
                    
                    background: Rectangle {
                        color: "white"
                        border.color: searchInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: searchInput.focus ? 2 : 1
                        radius: 4
                    }
                    
                    onTextChanged: filterData()
                }
                
                // 分类选择
                ComboBox {
                    id: categoryCombo
                    Layout.preferredWidth: 200
                    model: nnCategories
                    currentIndex: selectedCategoryIndex
                    
                    background: Rectangle {
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                    }
                    
                    onCurrentIndexChanged: {
                        selectedCategoryIndex = currentIndex
                        filterData()
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "共 " + filteredData.length + " 项"
                    font.pixelSize: 13
                    color: "#666"
                }
            }
            
            // 主内容区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // 左侧列表
                Rectangle {
                    Layout.preferredWidth: 500
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    clip: true
                    
                    // 表头
                    Rectangle {
                        id: listHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 40
                        color: "#f5f5f5"
                        z: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 10
                            
                            Text {
                                text: "层名称"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 150
                            }
                            
                            Text {
                                text: "分类"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 140
                            }
                            
                            Text {
                                text: "描述"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    // 数据列表
                    ListView {
                        id: listView
                        anchors.top: listHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 1
                        clip: true
                        model: filteredData
                        
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                        
                        delegate: Rectangle {
                            width: listView.width
                            height: 42
                            color: selectedLayer && selectedLayer.name === modelData.name ? "#e3f2fd" : (index % 2 === 0 ? "white" : "#fafafa")
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                spacing: 10
                                
                                Text {
                                    text: "nn." + modelData.name
                                    font.pixelSize: 13
                                    font.family: "Consolas"
                                    font.bold: true
                                    color: "#1976d2"
                                    Layout.preferredWidth: 150
                                }
                                
                                Text {
                                    text: modelData.category.split(" ")[0]
                                    font.pixelSize: 12
                                    color: "#666"
                                    Layout.preferredWidth: 140
                                }
                                
                                Text {
                                    text: modelData.desc
                                    font.pixelSize: 12
                                    color: "#333"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    selectedLayer = modelData
                                }
                            }
                        }
                    }
                }
                
                // 右侧详情
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // 标题
                        Text {
                            text: selectedLayer ? "nn." + selectedLayer.name : "选择一个层查看详情"
                            font.pixelSize: 20
                            font.bold: true
                            font.family: "Consolas"
                            color: selectedLayer ? "#1976d2" : "#999"
                        }
                        
                        // 分类标签
                        Rectangle {
                            visible: selectedLayer !== null
                            width: categoryLabel.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: "#e3f2fd"
                            
                            Text {
                                id: categoryLabel
                                anchors.centerIn: parent
                                text: selectedLayer ? selectedLayer.category : ""
                                font.pixelSize: 12
                                color: "#1976d2"
                            }
                        }
                        
                        // 分隔线
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#e0e0e0"
                            visible: selectedLayer !== null
                        }
                        
                        // 描述
                        Column {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: selectedLayer !== null
                            
                            Text {
                                text: "描述"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Text {
                                text: selectedLayer ? selectedLayer.desc : ""
                                font.pixelSize: 14
                                color: "#666"
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }
                        
                        // 用法
                        Column {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: selectedLayer !== null
                            
                            RowLayout {
                                width: parent.width
                                
                                Text {
                                    text: "用法示例"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "复制"
                                    implicitWidth: 60
                                    implicitHeight: 28
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        color: "#1976d2"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "white")
                                        border.color: "#1976d2"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    onClicked: {
                                        if (selectedLayer) {
                                            copyToClipboard(selectedLayer.usage)
                                            copyToast.visible = true
                                            toastTimer.restart()
                                        }
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: usageText.implicitHeight + 20
                                color: "#2d2d2d"
                                radius: 4
                                
                                Text {
                                    id: usageText
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    text: selectedLayer ? selectedLayer.usage : ""
                                    font.pixelSize: 14
                                    font.family: "Consolas"
                                    color: "#a5d6a7"
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                        
                        // 文档链接
                        Row {
                            spacing: 10
                            visible: selectedLayer !== null
                            
                            Text {
                                text: "官方文档："
                                font.pixelSize: 13
                                color: "#666"
                            }
                            
                            Text {
                                text: selectedLayer ? "https://pytorch.org/docs/stable/generated/torch.nn." + selectedLayer.name + ".html" : ""
                                font.pixelSize: 13
                                color: "#1976d2"
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (selectedLayer) {
                                            Qt.openUrlExternally("https://pytorch.org/docs/stable/generated/torch.nn." + selectedLayer.name + ".html")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
        
        // 复制成功提示
        Rectangle {
            id: copyToast
            visible: false
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 30
            width: 140
            height: 36
            radius: 18
            color: "#323232"
            
            Text {
                anchors.centerIn: parent
                text: "✓ 已复制"
                font.pixelSize: 14
                color: "white"
            }
            
            Timer {
                id: toastTimer
                interval: 1500
                onTriggered: copyToast.visible = false
            }
        }
    }
}
