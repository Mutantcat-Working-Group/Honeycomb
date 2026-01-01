import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: kerasLayerWindow
    width: 1000
    height: 700
    minimumWidth: 800
    minimumHeight: 550
    title: "Layer对照表 - TensorFlow/Keras"
    flags: Qt.Window

    // 分类数据
    property var categories: [
        "全部",
        "Core Layers",
        "Convolution Layers",
        "Pooling Layers",
        "Recurrent Layers",
        "Attention Layers",
        "Normalization Layers",
        "Regularization Layers",
        "Reshaping Layers",
        "Merging Layers",
        "Activation Layers",
        "Preprocessing Layers",
        "Image Preprocessing",
        "Wrapper Layers"
    ]

    // Keras层数据
    property var layersData: [
        // Core Layers
        { name: "Dense", category: "Core Layers", desc: "全连接层，最基础的神经网络层", usage: "Dense(units, activation=None, use_bias=True)", example: "tf.keras.layers.Dense(128, activation='relu')" },
        { name: "Activation", category: "Core Layers", desc: "对输出应用激活函数", usage: "Activation(activation)", example: "tf.keras.layers.Activation('relu')" },
        { name: "Embedding", category: "Core Layers", desc: "将正整数(索引)转换为固定大小的密集向量", usage: "Embedding(input_dim, output_dim)", example: "tf.keras.layers.Embedding(10000, 128)" },
        { name: "Masking", category: "Core Layers", desc: "使用掩码值跳过时间步", usage: "Masking(mask_value=0.0)", example: "tf.keras.layers.Masking(mask_value=0.)" },
        { name: "Lambda", category: "Core Layers", desc: "将任意表达式包装为Layer对象", usage: "Lambda(function)", example: "tf.keras.layers.Lambda(lambda x: x ** 2)" },
        { name: "InputLayer", category: "Core Layers", desc: "所有层继承的基类，用于定义输入", usage: "InputLayer(input_shape)", example: "tf.keras.layers.InputLayer(input_shape=(784,))" },
        { name: "EinsumDense", category: "Core Layers", desc: "使用einsum作为计算后端的层", usage: "EinsumDense(equation, output_shape)", example: "tf.keras.layers.EinsumDense('abc,cd->abd', (64,))" },
        { name: "Identity", category: "Core Layers", desc: "恒等层，直接输出输入", usage: "Identity()", example: "tf.keras.layers.Identity()" },

        // Convolution Layers
        { name: "Conv1D", category: "Convolution Layers", desc: "1D卷积层，用于时序数据", usage: "Conv1D(filters, kernel_size, strides=1, padding='valid')", example: "tf.keras.layers.Conv1D(64, 3, activation='relu')" },
        { name: "Conv2D", category: "Convolution Layers", desc: "2D卷积层，用于图像数据", usage: "Conv2D(filters, kernel_size, strides=(1,1), padding='valid')", example: "tf.keras.layers.Conv2D(32, (3, 3), activation='relu')" },
        { name: "Conv3D", category: "Convolution Layers", desc: "3D卷积层，用于视频或体积数据", usage: "Conv3D(filters, kernel_size, strides=(1,1,1))", example: "tf.keras.layers.Conv3D(32, (3, 3, 3), activation='relu')" },
        { name: "Conv1DTranspose", category: "Convolution Layers", desc: "1D转置卷积层", usage: "Conv1DTranspose(filters, kernel_size, strides=1)", example: "tf.keras.layers.Conv1DTranspose(64, 3, strides=2)" },
        { name: "Conv2DTranspose", category: "Convolution Layers", desc: "2D转置卷积层，常用于上采样", usage: "Conv2DTranspose(filters, kernel_size, strides=(1,1))", example: "tf.keras.layers.Conv2DTranspose(32, (3, 3), strides=(2, 2))" },
        { name: "Conv3DTranspose", category: "Convolution Layers", desc: "3D转置卷积层", usage: "Conv3DTranspose(filters, kernel_size)", example: "tf.keras.layers.Conv3DTranspose(32, (3, 3, 3))" },
        { name: "SeparableConv1D", category: "Convolution Layers", desc: "1D深度可分离卷积", usage: "SeparableConv1D(filters, kernel_size)", example: "tf.keras.layers.SeparableConv1D(64, 3)" },
        { name: "SeparableConv2D", category: "Convolution Layers", desc: "2D深度可分离卷积，参数更少", usage: "SeparableConv2D(filters, kernel_size)", example: "tf.keras.layers.SeparableConv2D(64, (3, 3))" },
        { name: "DepthwiseConv1D", category: "Convolution Layers", desc: "1D深度卷积", usage: "DepthwiseConv1D(kernel_size)", example: "tf.keras.layers.DepthwiseConv1D(3)" },
        { name: "DepthwiseConv2D", category: "Convolution Layers", desc: "2D深度卷积", usage: "DepthwiseConv2D(kernel_size)", example: "tf.keras.layers.DepthwiseConv2D((3, 3))" },

        // Pooling Layers
        { name: "MaxPool1D", category: "Pooling Layers", desc: "1D最大池化", usage: "MaxPool1D(pool_size=2, strides=None)", example: "tf.keras.layers.MaxPool1D(pool_size=2)" },
        { name: "MaxPool2D", category: "Pooling Layers", desc: "2D最大池化", usage: "MaxPool2D(pool_size=(2,2), strides=None)", example: "tf.keras.layers.MaxPool2D(pool_size=(2, 2))" },
        { name: "MaxPool3D", category: "Pooling Layers", desc: "3D最大池化", usage: "MaxPool3D(pool_size=(2,2,2))", example: "tf.keras.layers.MaxPool3D(pool_size=(2, 2, 2))" },
        { name: "AveragePooling1D", category: "Pooling Layers", desc: "1D平均池化", usage: "AveragePooling1D(pool_size=2)", example: "tf.keras.layers.AveragePooling1D(pool_size=2)" },
        { name: "AveragePooling2D", category: "Pooling Layers", desc: "2D平均池化", usage: "AveragePooling2D(pool_size=(2,2))", example: "tf.keras.layers.AveragePooling2D(pool_size=(2, 2))" },
        { name: "AveragePooling3D", category: "Pooling Layers", desc: "3D平均池化", usage: "AveragePooling3D(pool_size=(2,2,2))", example: "tf.keras.layers.AveragePooling3D(pool_size=(2, 2, 2))" },
        { name: "GlobalMaxPool1D", category: "Pooling Layers", desc: "1D全局最大池化", usage: "GlobalMaxPool1D()", example: "tf.keras.layers.GlobalMaxPool1D()" },
        { name: "GlobalMaxPool2D", category: "Pooling Layers", desc: "2D全局最大池化", usage: "GlobalMaxPool2D()", example: "tf.keras.layers.GlobalMaxPool2D()" },
        { name: "GlobalMaxPool3D", category: "Pooling Layers", desc: "3D全局最大池化", usage: "GlobalMaxPool3D()", example: "tf.keras.layers.GlobalMaxPool3D()" },
        { name: "GlobalAveragePooling1D", category: "Pooling Layers", desc: "1D全局平均池化", usage: "GlobalAveragePooling1D()", example: "tf.keras.layers.GlobalAveragePooling1D()" },
        { name: "GlobalAveragePooling2D", category: "Pooling Layers", desc: "2D全局平均池化", usage: "GlobalAveragePooling2D()", example: "tf.keras.layers.GlobalAveragePooling2D()" },
        { name: "GlobalAveragePooling3D", category: "Pooling Layers", desc: "3D全局平均池化", usage: "GlobalAveragePooling3D()", example: "tf.keras.layers.GlobalAveragePooling3D()" },

        // Recurrent Layers
        { name: "LSTM", category: "Recurrent Layers", desc: "长短期记忆网络 - Hochreiter 1997", usage: "LSTM(units, return_sequences=False)", example: "tf.keras.layers.LSTM(128, return_sequences=True)" },
        { name: "GRU", category: "Recurrent Layers", desc: "门控循环单元 - Cho et al. 2014", usage: "GRU(units, return_sequences=False)", example: "tf.keras.layers.GRU(128)" },
        { name: "SimpleRNN", category: "Recurrent Layers", desc: "全连接RNN，输出反馈作为输入", usage: "SimpleRNN(units)", example: "tf.keras.layers.SimpleRNN(64)" },
        { name: "LSTMCell", category: "Recurrent Layers", desc: "LSTM层的单元格类", usage: "LSTMCell(units)", example: "tf.keras.layers.LSTMCell(128)" },
        { name: "GRUCell", category: "Recurrent Layers", desc: "GRU层的单元格类", usage: "GRUCell(units)", example: "tf.keras.layers.GRUCell(128)" },
        { name: "SimpleRNNCell", category: "Recurrent Layers", desc: "SimpleRNN的单元格类", usage: "SimpleRNNCell(units)", example: "tf.keras.layers.SimpleRNNCell(64)" },
        { name: "RNN", category: "Recurrent Layers", desc: "循环层的基类", usage: "RNN(cell, return_sequences=False)", example: "tf.keras.layers.RNN(cell)" },
        { name: "Bidirectional", category: "Recurrent Layers", desc: "RNN的双向包装器", usage: "Bidirectional(layer, merge_mode='concat')", example: "tf.keras.layers.Bidirectional(LSTM(64))" },
        { name: "ConvLSTM1D", category: "Recurrent Layers", desc: "1D卷积LSTM", usage: "ConvLSTM1D(filters, kernel_size)", example: "tf.keras.layers.ConvLSTM1D(64, 3)" },
        { name: "ConvLSTM2D", category: "Recurrent Layers", desc: "2D卷积LSTM", usage: "ConvLSTM2D(filters, kernel_size)", example: "tf.keras.layers.ConvLSTM2D(64, (3, 3))" },
        { name: "ConvLSTM3D", category: "Recurrent Layers", desc: "3D卷积LSTM", usage: "ConvLSTM3D(filters, kernel_size)", example: "tf.keras.layers.ConvLSTM3D(64, (3, 3, 3))" },
        { name: "TimeDistributed", category: "Recurrent Layers", desc: "将层应用于输入的每个时间切片", usage: "TimeDistributed(layer)", example: "tf.keras.layers.TimeDistributed(Dense(64))" },
        { name: "StackedRNNCells", category: "Recurrent Layers", desc: "使一组RNN单元表现为单个单元", usage: "StackedRNNCells(cells)", example: "tf.keras.layers.StackedRNNCells([cell1, cell2])" },

        // Attention Layers
        { name: "MultiHeadAttention", category: "Attention Layers", desc: "多头注意力层", usage: "MultiHeadAttention(num_heads, key_dim)", example: "tf.keras.layers.MultiHeadAttention(num_heads=8, key_dim=64)" },
        { name: "Attention", category: "Attention Layers", desc: "点积注意力层，即Luong风格注意力", usage: "Attention(use_scale=False)", example: "tf.keras.layers.Attention()" },
        { name: "AdditiveAttention", category: "Attention Layers", desc: "加性注意力层，即Bahdanau风格注意力", usage: "AdditiveAttention(use_scale=True)", example: "tf.keras.layers.AdditiveAttention()" },
        { name: "GroupQueryAttention", category: "Attention Layers", desc: "分组查询注意力层", usage: "GroupQueryAttention(head_dim, num_query_heads, num_kv_heads)", example: "tf.keras.layers.GroupQueryAttention(64, 8, 4)" },

        // Normalization Layers
        { name: "BatchNormalization", category: "Normalization Layers", desc: "批量归一化层", usage: "BatchNormalization(axis=-1, momentum=0.99)", example: "tf.keras.layers.BatchNormalization()" },
        { name: "LayerNormalization", category: "Normalization Layers", desc: "层归一化 - Ba et al., 2016", usage: "LayerNormalization(axis=-1)", example: "tf.keras.layers.LayerNormalization()" },
        { name: "GroupNormalization", category: "Normalization Layers", desc: "组归一化层", usage: "GroupNormalization(groups=32)", example: "tf.keras.layers.GroupNormalization(groups=32)" },
        { name: "UnitNormalization", category: "Normalization Layers", desc: "单位归一化层", usage: "UnitNormalization(axis=-1)", example: "tf.keras.layers.UnitNormalization()" },
        { name: "SpectralNormalization", category: "Normalization Layers", desc: "对目标层的权重进行谱归一化", usage: "SpectralNormalization(layer)", example: "tf.keras.layers.SpectralNormalization(Dense(64))" },

        // Regularization Layers
        { name: "Dropout", category: "Regularization Layers", desc: "对输入应用Dropout", usage: "Dropout(rate, noise_shape=None)", example: "tf.keras.layers.Dropout(0.5)" },
        { name: "SpatialDropout1D", category: "Regularization Layers", desc: "1D Dropout的空间版本", usage: "SpatialDropout1D(rate)", example: "tf.keras.layers.SpatialDropout1D(0.2)" },
        { name: "SpatialDropout2D", category: "Regularization Layers", desc: "2D Dropout的空间版本", usage: "SpatialDropout2D(rate)", example: "tf.keras.layers.SpatialDropout2D(0.2)" },
        { name: "SpatialDropout3D", category: "Regularization Layers", desc: "3D Dropout的空间版本", usage: "SpatialDropout3D(rate)", example: "tf.keras.layers.SpatialDropout3D(0.2)" },
        { name: "GaussianDropout", category: "Regularization Layers", desc: "应用乘性1-中心高斯噪声", usage: "GaussianDropout(rate)", example: "tf.keras.layers.GaussianDropout(0.2)" },
        { name: "GaussianNoise", category: "Regularization Layers", desc: "应用加性零中心高斯噪声", usage: "GaussianNoise(stddev)", example: "tf.keras.layers.GaussianNoise(0.1)" },
        { name: "ActivityRegularization", category: "Regularization Layers", desc: "基于输入活动更新代价函数的层", usage: "ActivityRegularization(l1=0.0, l2=0.0)", example: "tf.keras.layers.ActivityRegularization(l1=0.01)" },

        // Reshaping Layers
        { name: "Reshape", category: "Reshaping Layers", desc: "将输入重塑为给定形状", usage: "Reshape(target_shape)", example: "tf.keras.layers.Reshape((3, 4))" },
        { name: "Flatten", category: "Reshaping Layers", desc: "展平输入，不影响批大小", usage: "Flatten()", example: "tf.keras.layers.Flatten()" },
        { name: "RepeatVector", category: "Reshaping Layers", desc: "将输入重复n次", usage: "RepeatVector(n)", example: "tf.keras.layers.RepeatVector(3)" },
        { name: "Permute", category: "Reshaping Layers", desc: "按给定模式排列输入维度", usage: "Permute(dims)", example: "tf.keras.layers.Permute((2, 1))" },
        { name: "Cropping1D", category: "Reshaping Layers", desc: "1D输入的裁剪层", usage: "Cropping1D(cropping=(1, 1))", example: "tf.keras.layers.Cropping1D(cropping=(1, 1))" },
        { name: "Cropping2D", category: "Reshaping Layers", desc: "2D输入的裁剪层", usage: "Cropping2D(cropping=((0,0),(0,0)))", example: "tf.keras.layers.Cropping2D(cropping=((2, 2), (4, 4)))" },
        { name: "Cropping3D", category: "Reshaping Layers", desc: "3D数据的裁剪层", usage: "Cropping3D(cropping=((1,1),(1,1),(1,1)))", example: "tf.keras.layers.Cropping3D(cropping=((1, 1), (2, 2), (2, 2)))" },
        { name: "UpSampling1D", category: "Reshaping Layers", desc: "1D输入的上采样层", usage: "UpSampling1D(size=2)", example: "tf.keras.layers.UpSampling1D(size=2)" },
        { name: "UpSampling2D", category: "Reshaping Layers", desc: "2D输入的上采样层", usage: "UpSampling2D(size=(2,2))", example: "tf.keras.layers.UpSampling2D(size=(2, 2))" },
        { name: "UpSampling3D", category: "Reshaping Layers", desc: "3D输入的上采样层", usage: "UpSampling3D(size=(2,2,2))", example: "tf.keras.layers.UpSampling3D(size=(2, 2, 2))" },
        { name: "ZeroPadding1D", category: "Reshaping Layers", desc: "1D输入的零填充层", usage: "ZeroPadding1D(padding=1)", example: "tf.keras.layers.ZeroPadding1D(padding=1)" },
        { name: "ZeroPadding2D", category: "Reshaping Layers", desc: "2D输入的零填充层", usage: "ZeroPadding2D(padding=(1,1))", example: "tf.keras.layers.ZeroPadding2D(padding=(1, 1))" },
        { name: "ZeroPadding3D", category: "Reshaping Layers", desc: "3D数据的零填充层", usage: "ZeroPadding3D(padding=(1,1,1))", example: "tf.keras.layers.ZeroPadding3D(padding=(1, 1, 1))" },

        // Merging Layers
        { name: "Concatenate", category: "Merging Layers", desc: "连接输入列表", usage: "Concatenate(axis=-1)", example: "tf.keras.layers.Concatenate()([x1, x2])" },
        { name: "Add", category: "Merging Layers", desc: "逐元素相加", usage: "Add()", example: "tf.keras.layers.Add()([x1, x2])" },
        { name: "Subtract", category: "Merging Layers", desc: "逐元素相减", usage: "Subtract()", example: "tf.keras.layers.Subtract()([x1, x2])" },
        { name: "Multiply", category: "Merging Layers", desc: "逐元素相乘", usage: "Multiply()", example: "tf.keras.layers.Multiply()([x1, x2])" },
        { name: "Average", category: "Merging Layers", desc: "逐元素平均", usage: "Average()", example: "tf.keras.layers.Average()([x1, x2])" },
        { name: "Maximum", category: "Merging Layers", desc: "逐元素取最大值", usage: "Maximum()", example: "tf.keras.layers.Maximum()([x1, x2])" },
        { name: "Minimum", category: "Merging Layers", desc: "逐元素取最小值", usage: "Minimum()", example: "tf.keras.layers.Minimum()([x1, x2])" },
        { name: "Dot", category: "Merging Layers", desc: "计算两个张量的逐元素点积", usage: "Dot(axes)", example: "tf.keras.layers.Dot(axes=1)([x1, x2])" },

        // Activation Layers
        { name: "ReLU", category: "Activation Layers", desc: "线性整流函数激活层", usage: "ReLU(max_value=None, negative_slope=0.0)", example: "tf.keras.layers.ReLU()" },
        { name: "LeakyReLU", category: "Activation Layers", desc: "带泄漏的ReLU激活层", usage: "LeakyReLU(alpha=0.3)", example: "tf.keras.layers.LeakyReLU(alpha=0.1)" },
        { name: "PReLU", category: "Activation Layers", desc: "参数化整流线性单元", usage: "PReLU(alpha_initializer='zeros')", example: "tf.keras.layers.PReLU()" },
        { name: "ELU", category: "Activation Layers", desc: "指数线性单元", usage: "ELU(alpha=1.0)", example: "tf.keras.layers.ELU(alpha=1.0)" },
        { name: "Softmax", category: "Activation Layers", desc: "Softmax激活层", usage: "Softmax(axis=-1)", example: "tf.keras.layers.Softmax()" },

        // Preprocessing Layers
        { name: "Normalization", category: "Preprocessing Layers", desc: "归一化连续特征的预处理层", usage: "Normalization(axis=-1)", example: "tf.keras.layers.Normalization()" },
        { name: "Discretization", category: "Preprocessing Layers", desc: "按范围分桶连续特征", usage: "Discretization(bin_boundaries=None, num_bins=None)", example: "tf.keras.layers.Discretization(bin_boundaries=[0., 0.5, 1.])" },
        { name: "CategoryEncoding", category: "Preprocessing Layers", desc: "编码整数特征的预处理层", usage: "CategoryEncoding(num_tokens, output_mode='multi_hot')", example: "tf.keras.layers.CategoryEncoding(num_tokens=10)" },
        { name: "Hashing", category: "Preprocessing Layers", desc: "哈希分桶分类特征", usage: "Hashing(num_bins, mask_value=None)", example: "tf.keras.layers.Hashing(num_bins=3)" },
        { name: "HashedCrossing", category: "Preprocessing Layers", desc: "使用哈希技巧交叉特征", usage: "HashedCrossing(num_bins, output_mode='int')", example: "tf.keras.layers.HashedCrossing(num_bins=5)" },
        { name: "StringLookup", category: "Preprocessing Layers", desc: "将字符串映射到索引", usage: "StringLookup(vocabulary=None)", example: "tf.keras.layers.StringLookup(vocabulary=['a', 'b', 'c'])" },
        { name: "IntegerLookup", category: "Preprocessing Layers", desc: "将整数映射到索引", usage: "IntegerLookup(vocabulary=None)", example: "tf.keras.layers.IntegerLookup(vocabulary=[1, 2, 3])" },
        { name: "TextVectorization", category: "Preprocessing Layers", desc: "将文本特征映射到整数序列", usage: "TextVectorization(max_tokens=None)", example: "tf.keras.layers.TextVectorization(max_tokens=10000)" },
        { name: "Rescaling", category: "Preprocessing Layers", desc: "将输入值缩放到新范围", usage: "Rescaling(scale, offset=0.0)", example: "tf.keras.layers.Rescaling(1./255)" },
        { name: "MelSpectrogram", category: "Preprocessing Layers", desc: "将原始音频信号转换为梅尔频谱图", usage: "MelSpectrogram(fft_length=2048)", example: "tf.keras.layers.MelSpectrogram()" },

        // Image Preprocessing
        { name: "Resizing", category: "Image Preprocessing", desc: "调整图像大小的预处理层", usage: "Resizing(height, width)", example: "tf.keras.layers.Resizing(224, 224)" },
        { name: "CenterCrop", category: "Image Preprocessing", desc: "中心裁剪图像的预处理层", usage: "CenterCrop(height, width)", example: "tf.keras.layers.CenterCrop(128, 128)" },
        { name: "RandomCrop", category: "Image Preprocessing", desc: "训练时随机裁剪图像", usage: "RandomCrop(height, width)", example: "tf.keras.layers.RandomCrop(224, 224)" },
        { name: "RandomFlip", category: "Image Preprocessing", desc: "训练时随机翻转图像", usage: "RandomFlip(mode='horizontal_and_vertical')", example: "tf.keras.layers.RandomFlip('horizontal')" },
        { name: "RandomRotation", category: "Image Preprocessing", desc: "训练时随机旋转图像", usage: "RandomRotation(factor)", example: "tf.keras.layers.RandomRotation(0.2)" },
        { name: "RandomZoom", category: "Image Preprocessing", desc: "训练时随机缩放图像", usage: "RandomZoom(height_factor, width_factor=None)", example: "tf.keras.layers.RandomZoom(0.2)" },
        { name: "RandomTranslation", category: "Image Preprocessing", desc: "训练时随机平移图像", usage: "RandomTranslation(height_factor, width_factor)", example: "tf.keras.layers.RandomTranslation(0.1, 0.1)" },
        { name: "RandomContrast", category: "Image Preprocessing", desc: "训练时随机调整对比度", usage: "RandomContrast(factor)", example: "tf.keras.layers.RandomContrast(0.2)" },
        { name: "RandomBrightness", category: "Image Preprocessing", desc: "训练时随机调整亮度", usage: "RandomBrightness(factor)", example: "tf.keras.layers.RandomBrightness(0.2)" },

        // Wrapper Layers
        { name: "Wrapper", category: "Wrapper Layers", desc: "抽象包装器基类", usage: "Wrapper(layer)", example: "自定义包装器继承此类" },
        { name: "TorchModuleWrapper", category: "Wrapper Layers", desc: "Torch模块包装层", usage: "TorchModuleWrapper(module)", example: "tf.keras.layers.TorchModuleWrapper(torch_module)" },
        { name: "JaxLayer", category: "Wrapper Layers", desc: "包装JAX模型的Keras层", usage: "JaxLayer(call_fn, init_fn=None)", example: "tf.keras.layers.JaxLayer(jax_fn)" },
        { name: "FlaxLayer", category: "Wrapper Layers", desc: "包装Flax模块的Keras层", usage: "FlaxLayer(flax_module)", example: "tf.keras.layers.FlaxLayer(flax_module)" },
        { name: "TFSMLayer", category: "Wrapper Layers", desc: "重新加载通过SavedModel保存的Keras模型", usage: "TFSMLayer(filepath)", example: "tf.keras.layers.TFSMLayer('saved_model/')" }
    ]

    // 当前选中的分类
    property string selectedCategory: "全部"
    // 搜索关键词
    property string searchKeyword: ""
    // 当前选中的层索引
    property int selectedLayerIndex: -1

    // 过滤后的层列表
    property var filteredLayers: {
        var result = [];
        for (var i = 0; i < layersData.length; i++) {
            var layer = layersData[i];
            var matchCategory = (selectedCategory === "全部" || layer.category === selectedCategory);
            var matchSearch = (searchKeyword === "" || 
                layer.name.toLowerCase().indexOf(searchKeyword.toLowerCase()) >= 0 ||
                layer.desc.toLowerCase().indexOf(searchKeyword.toLowerCase()) >= 0);
            if (matchCategory && matchSearch) {
                result.push(layer);
            }
        }
        return result;
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    text: "TensorFlow/Keras Layer 对照表"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333"
                }

                Item { Layout.fillWidth: true }

                // 搜索框
                Rectangle {
                    width: 220
                    height: 32
                    color: "white"
                    radius: 4
                    border.color: "#ddd"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Text {
                            text: "\u{1F50D}"
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            clip: true
                            selectByMouse: true
                            onTextChanged: searchKeyword = text

                            Text {
                                anchors.fill: parent
                                text: "搜索层名称或描述..."
                                color: "#999"
                                font.pixelSize: 13
                                visible: !parent.text && !parent.activeFocus
                            }
                        }
                    }
                }

                // 分类选择
                ComboBox {
                    id: categoryCombo
                    width: 160
                    height: 32
                    model: categories
                    onCurrentTextChanged: {
                        selectedCategory = currentText;
                        selectedLayerIndex = -1;
                    }
                }
            }

            // 主内容区
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // 层列表
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#e0e0e0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0

                        // 列表头
                        Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            color: "#f5f5f5"
                            radius: 8

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 8
                                color: "#f5f5f5"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text {
                                    text: "层名称"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#666"
                                    Layout.preferredWidth: 120
                                }
                                Text {
                                    text: "分类"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#666"
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // 层列表
                        ListView {
                            id: layerListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: filteredLayers

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: layerListView.width
                                height: 40
                                color: selectedLayerIndex === index ? "#e3f2fd" : (mouseArea.containsMouse ? "#f5f5f5" : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 13
                                        font.bold: selectedLayerIndex === index
                                        color: selectedLayerIndex === index ? "#1976d2" : "#333"
                                        Layout.preferredWidth: 120
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.category
                                        font.pixelSize: 12
                                        color: "#888"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: selectedLayerIndex = index
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    height: 1
                                    color: "#f0f0f0"
                                }
                            }
                        }

                        // 统计信息
                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            color: "#fafafa"
                            radius: 8

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 8
                                color: "#fafafa"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "共 " + filteredLayers.length + " 个层"
                                font.pixelSize: 12
                                color: "#888"
                            }
                        }
                    }
                }

                // 详情面板
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#e0e0e0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // 未选中提示
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: selectedLayerIndex < 0

                            Column {
                                anchors.centerIn: parent
                                spacing: 12

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "\u{1F4DA}"
                                    font.pixelSize: 48
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "请从左侧列表选择一个层"
                                    font.pixelSize: 14
                                    color: "#888"
                                }
                            }
                        }

                        // 详情内容
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 16
                            visible: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length

                            // 层名称和分类
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].name : ""
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#1976d2"
                                }

                                Rectangle {
                                    width: categoryTag.width + 16
                                    height: 24
                                    radius: 12
                                    color: "#e8f5e9"

                                    Text {
                                        id: categoryTag
                                        anchors.centerIn: parent
                                        text: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].category : ""
                                        font.pixelSize: 12
                                        color: "#4caf50"
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    text: "查看文档"
                                    font.pixelSize: 12
                                    onClicked: {
                                        if (selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length) {
                                            var layerName = filteredLayers[selectedLayerIndex].name;
                                            Qt.openUrlExternally("https://www.tensorflow.org/api_docs/python/tf/keras/layers/" + layerName);
                                        }
                                    }
                                }
                            }

                            // 描述
                            Rectangle {
                                Layout.fillWidth: true
                                height: descText.height + 24
                                color: "#f8f9fa"
                                radius: 6

                                Text {
                                    id: descText
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: 12
                                    text: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].desc : ""
                                    font.pixelSize: 14
                                    color: "#555"
                                    wrapMode: Text.Wrap
                                }
                            }

                            // 用法
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "用法"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: usageText.height + 20
                                    color: "#263238"
                                    radius: 6

                                    Text {
                                        id: usageText
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 12
                                        text: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].usage : ""
                                        font.family: "Consolas"
                                        font.pixelSize: 13
                                        color: "#aed581"
                                        wrapMode: Text.Wrap
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length) {
                                                var textToCopy = filteredLayers[selectedLayerIndex].usage;
                                                clipboardHelper.text = textToCopy;
                                                clipboardHelper.selectAll();
                                                clipboardHelper.copy();
                                            }
                                        }

                                        ToolTip.visible: containsMouse
                                        ToolTip.text: "点击复制"
                                        ToolTip.delay: 500
                                    }
                                }
                            }

                            // 示例
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "示例"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: exampleText.height + 20
                                    color: "#1e1e1e"
                                    radius: 6

                                    Text {
                                        id: exampleText
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 12
                                        text: selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].example : ""
                                        font.family: "Consolas"
                                        font.pixelSize: 13
                                        color: "#ce9178"
                                        wrapMode: Text.Wrap
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length) {
                                                var textToCopy = filteredLayers[selectedLayerIndex].example;
                                                clipboardHelper.text = textToCopy;
                                                clipboardHelper.selectAll();
                                                clipboardHelper.copy();
                                            }
                                        }

                                        ToolTip.visible: containsMouse
                                        ToolTip.text: "点击复制"
                                        ToolTip.delay: 500
                                    }
                                }
                            }

                            // 快速参考
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "快速参考"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: refContent.height + 24
                                    color: "#fff8e1"
                                    radius: 6
                                    border.color: "#ffe082"

                                    Column {
                                        id: refContent
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 12
                                        spacing: 6

                                        Text {
                                            width: parent.width
                                            text: "模块路径: tf.keras.layers." + (selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].name : "")
                                            font.pixelSize: 12
                                            color: "#6d4c41"
                                            wrapMode: Text.Wrap
                                        }

                                        Text {
                                            width: parent.width
                                            text: "导入方式: from tensorflow.keras.layers import " + (selectedLayerIndex >= 0 && selectedLayerIndex < filteredLayers.length ? filteredLayers[selectedLayerIndex].name : "")
                                            font.pixelSize: 12
                                            color: "#6d4c41"
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }

    // 辅助复制文本
    TextEdit {
        id: clipboardHelper
        visible: false
    }
}
