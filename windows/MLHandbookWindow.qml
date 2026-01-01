import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: mlHandbookWindow
    width: 1050
    height: 720
    minimumWidth: 850
    minimumHeight: 600
    title: "机器学习手书"
    flags: Qt.Window

    // 分类数据
    property var categories: [
        "全部",
        "监督学习 - 回归",
        "监督学习 - 分类",
        "无监督学习",
        "集成学习",
        "降维算法",
        "聚类算法",
        "深度学习",
        "强化学习",
        "概率图模型",
        "优化算法"
    ]

    // 机器学习算法数据
    property var algorithmsData: [
        // 监督学习 - 回归
        {
            name: "线性回归",
            nameEn: "Linear Regression",
            category: "监督学习 - 回归",
            desc: "通过拟合线性方程来预测连续数值的基础回归算法",
            principle: "最小化预测值与真实值之间的均方误差，找到最优的权重参数",
            formula: "y = w₀ + w₁x₁ + w₂x₂ + ... + wₙxₙ",
            pros: "简单易懂、计算速度快、可解释性强",
            cons: "只能拟合线性关系、对异常值敏感",
            applications: "房价预测、销售预测、趋势分析",
            libraries: "sklearn.linear_model.LinearRegression"
        },
        {
            name: "岭回归",
            nameEn: "Ridge Regression",
            category: "监督学习 - 回归",
            desc: "带有L2正则化的线性回归，防止过拟合",
            principle: "在线性回归损失函数上添加L2范数惩罚项，约束权重大小",
            formula: "Loss = MSE + alpha * sum(w²)",
            pros: "防止过拟合、处理多重共线性",
            cons: "不能进行特征选择、需要调节正则化参数",
            applications: "高维数据回归、存在多重共线性的场景",
            libraries: "sklearn.linear_model.Ridge"
        },
        {
            name: "Lasso回归",
            nameEn: "Lasso Regression",
            category: "监督学习 - 回归",
            desc: "带有L1正则化的线性回归，可进行特征选择",
            principle: "在损失函数上添加L1范数惩罚项，使部分权重变为0",
            formula: "Loss = MSE + alpha * sum(|w|)",
            pros: "自动特征选择、模型稀疏化",
            cons: "在特征高度相关时不稳定",
            applications: "特征选择、稀疏模型构建",
            libraries: "sklearn.linear_model.Lasso"
        },
        {
            name: "多项式回归",
            nameEn: "Polynomial Regression",
            category: "监督学习 - 回归",
            desc: "通过引入多项式特征拟合非线性关系",
            principle: "将特征扩展为多项式形式，再进行线性回归",
            formula: "y = w₀ + w₁x + w₂x² + ... + wₙxⁿ",
            pros: "可以拟合非线性关系",
            cons: "容易过拟合、需要选择合适的多项式阶数",
            applications: "曲线拟合、非线性趋势预测",
            libraries: "sklearn.preprocessing.PolynomialFeatures"
        },
        {
            name: "弹性网络",
            nameEn: "Elastic Net",
            category: "监督学习 - 回归",
            desc: "结合L1和L2正则化的线性回归",
            principle: "同时使用L1和L2惩罚项，平衡特征选择和权重约束",
            formula: "Loss = MSE + alpha1 * sum(|w|) + alpha2 * sum(w²)",
            pros: "兼具Ridge和Lasso的优点",
            cons: "需要调节两个正则化参数",
            applications: "高维数据、特征相关性强的场景",
            libraries: "sklearn.linear_model.ElasticNet"
        },

        // 监督学习 - 分类
        {
            name: "逻辑回归",
            nameEn: "Logistic Regression",
            category: "监督学习 - 分类",
            desc: "使用Sigmoid函数进行二分类的线性分类器",
            principle: "将线性回归输出通过Sigmoid函数映射到(0,1)区间作为概率",
            formula: "P(y=1|x) = 1 / (1 + e^(-wx))",
            pros: "简单高效、输出概率、可解释性强",
            cons: "只能处理线性可分问题",
            applications: "二分类任务、点击率预测、信用评分",
            libraries: "sklearn.linear_model.LogisticRegression"
        },
        {
            name: "K近邻",
            nameEn: "K-Nearest Neighbors (KNN)",
            category: "监督学习 - 分类",
            desc: "基于实例的学习算法，通过最近的K个邻居投票分类",
            principle: "计算待分类样本与训练样本的距离，取最近K个样本投票决定类别",
            formula: "距离度量: d(x,y) = sqrt(sum((xi-yi)²))",
            pros: "简单直观、无需训练、适合多分类",
            cons: "计算复杂度高、对K值敏感、维度灾难",
            applications: "推荐系统、图像识别、异常检测",
            libraries: "sklearn.neighbors.KNeighborsClassifier"
        },
        {
            name: "支持向量机",
            nameEn: "Support Vector Machine (SVM)",
            category: "监督学习 - 分类",
            desc: "寻找最大间隔超平面的分类算法",
            principle: "找到能够最大化类别间间隔的决策边界，通过核技巧处理非线性",
            formula: "max margin = 2/||w||, s.t. yi(w·xi+b) >= 1",
            pros: "高维空间有效、核技巧灵活、泛化能力强",
            cons: "大规模数据训练慢、参数调优复杂",
            applications: "文本分类、图像识别、生物信息学",
            libraries: "sklearn.svm.SVC"
        },
        {
            name: "朴素贝叶斯",
            nameEn: "Naive Bayes",
            category: "监督学习 - 分类",
            desc: "基于贝叶斯定理和特征条件独立假设的分类器",
            principle: "利用贝叶斯定理计算后验概率，假设特征之间相互独立",
            formula: "P(y|x) = P(x|y)P(y) / P(x)",
            pros: "计算速度快、适合高维数据、小样本表现好",
            cons: "特征独立假设往往不成立",
            applications: "垃圾邮件过滤、文本分类、情感分析",
            libraries: "sklearn.naive_bayes.GaussianNB"
        },
        {
            name: "决策树",
            nameEn: "Decision Tree",
            category: "监督学习 - 分类",
            desc: "通过树形结构进行决策的分类算法",
            principle: "递归选择最优特征进行分裂，构建树形决策规则",
            formula: "信息增益: IG = H(D) - sum(|Dv|/|D| * H(Dv))",
            pros: "可解释性强、可视化、处理混合数据",
            cons: "容易过拟合、不稳定",
            applications: "风险评估、医疗诊断、客户分群",
            libraries: "sklearn.tree.DecisionTreeClassifier"
        },

        // 集成学习
        {
            name: "随机森林",
            nameEn: "Random Forest",
            category: "集成学习",
            desc: "由多棵决策树组成的集成学习算法",
            principle: "通过Bootstrap采样和随机特征选择构建多棵树，投票决定结果",
            formula: "y = mode({h₁(x), h₂(x), ..., hₙ(x)})",
            pros: "抗过拟合、处理高维数据、可评估特征重要性",
            cons: "模型较大、可解释性降低",
            applications: "分类回归、特征选择、异常检测",
            libraries: "sklearn.ensemble.RandomForestClassifier"
        },
        {
            name: "梯度提升树",
            nameEn: "Gradient Boosting (GBDT)",
            category: "集成学习",
            desc: "通过梯度下降迭代构建树的Boosting算法",
            principle: "每一轮拟合前一轮残差的负梯度方向，逐步减小误差",
            formula: "Fₘ(x) = Fₘ₋₁(x) + gamma * hₘ(x)",
            pros: "精度高、灵活性强",
            cons: "训练时间长、容易过拟合、需要仔细调参",
            applications: "排序、点击率预测、风控模型",
            libraries: "sklearn.ensemble.GradientBoostingClassifier"
        },
        {
            name: "XGBoost",
            nameEn: "eXtreme Gradient Boosting",
            category: "集成学习",
            desc: "优化的分布式梯度提升算法",
            principle: "在GBDT基础上加入正则化、并行计算和剪枝优化",
            formula: "Obj = sum(L(yi,y^i)) + sum(Omega(fk))",
            pros: "速度快、精度高、支持分布式、内置正则化",
            cons: "参数多、调参复杂",
            applications: "竞赛首选、CTR预测、风控",
            libraries: "xgboost.XGBClassifier"
        },
        {
            name: "LightGBM",
            nameEn: "Light Gradient Boosting Machine",
            category: "集成学习",
            desc: "基于直方图的快速梯度提升框架",
            principle: "使用基于直方图的决策树算法和Leaf-wise生长策略",
            formula: "使用GOSS和EFB技术加速训练",
            pros: "训练速度更快、内存占用更低、支持类别特征",
            cons: "小数据集可能过拟合",
            applications: "大规模数据、实时预测",
            libraries: "lightgbm.LGBMClassifier"
        },
        {
            name: "CatBoost",
            nameEn: "Categorical Boosting",
            category: "集成学习",
            desc: "专门处理类别特征的梯度提升算法",
            principle: "使用有序提升和对称树结构，原生支持类别特征",
            formula: "Ordered Target Statistics编码类别特征",
            pros: "类别特征处理好、默认参数表现优秀",
            cons: "训练时间相对较长",
            applications: "包含大量类别特征的任务",
            libraries: "catboost.CatBoostClassifier"
        },
        {
            name: "AdaBoost",
            nameEn: "Adaptive Boosting",
            category: "集成学习",
            desc: "自适应调整样本权重的Boosting算法",
            principle: "迭代调整样本权重，使分错的样本获得更高权重",
            formula: "H(x) = sign(sum(alpha_t * ht(x)))",
            pros: "简单有效、不易过拟合",
            cons: "对噪声敏感、受异常值影响大",
            applications: "人脸检测、二分类任务",
            libraries: "sklearn.ensemble.AdaBoostClassifier"
        },
        {
            name: "Bagging",
            nameEn: "Bootstrap Aggregating",
            category: "集成学习",
            desc: "通过Bootstrap采样训练多个模型的并行集成方法",
            principle: "有放回抽样生成多个子训练集，训练多个基学习器后投票",
            formula: "y = mode/mean({h₁(x), h₂(x), ..., hₙ(x)})",
            pros: "降低方差、抗过拟合",
            cons: "不能降低偏差",
            applications: "与决策树结合使用",
            libraries: "sklearn.ensemble.BaggingClassifier"
        },
        {
            name: "Stacking",
            nameEn: "Stacked Generalization",
            category: "集成学习",
            desc: "使用元学习器整合多个基学习器的集成方法",
            principle: "用基学习器的预测结果作为特征训练元学习器",
            formula: "y = meta_learner(h₁(x), h₂(x), ..., hₙ(x))",
            pros: "可组合不同类型模型、通常表现更好",
            cons: "复杂度高、训练时间长",
            applications: "竞赛中提升最终精度",
            libraries: "sklearn.ensemble.StackingClassifier"
        },

        // 无监督学习
        {
            name: "K-Means聚类",
            nameEn: "K-Means Clustering",
            category: "聚类算法",
            desc: "基于距离的划分聚类算法",
            principle: "迭代更新聚类中心，最小化样本到聚类中心的距离和",
            formula: "J = sum_k sum_i ||xi - uk||²",
            pros: "简单快速、适合大规模数据",
            cons: "需预设K值、对初始中心敏感、只能发现球形簇",
            applications: "客户分群、图像压缩、数据预处理",
            libraries: "sklearn.cluster.KMeans"
        },
        {
            name: "层次聚类",
            nameEn: "Hierarchical Clustering",
            category: "聚类算法",
            desc: "构建层次化聚类树的聚类算法",
            principle: "自底向上(凝聚)或自顶向下(分裂)构建聚类层次树",
            formula: "距离度量: 单链接、全链接、平均链接等",
            pros: "不需预设簇数、可生成聚类树、可视化好",
            cons: "计算复杂度高O(n²)、不可逆",
            applications: "基因分析、文档聚类、社交网络分析",
            libraries: "sklearn.cluster.AgglomerativeClustering"
        },
        {
            name: "DBSCAN",
            nameEn: "Density-Based Spatial Clustering",
            category: "聚类算法",
            desc: "基于密度的空间聚类算法",
            principle: "以密度为标准划分簇，能发现任意形状的簇",
            formula: "核心点: |N_eps(p)| >= MinPts",
            pros: "不需预设簇数、可发现任意形状、自动识别噪声",
            cons: "对参数敏感、密度不均匀时效果差",
            applications: "异常检测、地理数据聚类、噪声过滤",
            libraries: "sklearn.cluster.DBSCAN"
        },
        {
            name: "高斯混合模型",
            nameEn: "Gaussian Mixture Model (GMM)",
            category: "聚类算法",
            desc: "假设数据由多个高斯分布混合生成的概率模型",
            principle: "使用EM算法估计混合高斯分布的参数",
            formula: "P(x) = sum_k pi_k * N(x|mu_k, sigma_k)",
            pros: "软聚类、可估计概率、灵活性高",
            cons: "对初始值敏感、假设高斯分布",
            applications: "密度估计、软聚类、异常检测",
            libraries: "sklearn.mixture.GaussianMixture"
        },
        {
            name: "Mean Shift",
            nameEn: "Mean Shift Clustering",
            category: "聚类算法",
            desc: "基于核密度估计的聚类算法",
            principle: "迭代将点移动到核密度估计的局部最大值",
            formula: "m(x) = sum(K(x-xi)*xi) / sum(K(x-xi))",
            pros: "不需预设簇数、可发现任意形状",
            cons: "计算复杂度高、带宽选择困难",
            applications: "图像分割、目标跟踪",
            libraries: "sklearn.cluster.MeanShift"
        },

        // 降维算法
        {
            name: "主成分分析",
            nameEn: "Principal Component Analysis (PCA)",
            category: "降维算法",
            desc: "通过正交变换提取主成分的线性降维方法",
            principle: "找到数据方差最大的方向作为主成分",
            formula: "Z = XW, 其中W是特征向量矩阵",
            pros: "去除冗余、降低维度、去噪",
            cons: "只能进行线性变换、主成分难解释",
            applications: "数据可视化、特征提取、图像压缩",
            libraries: "sklearn.decomposition.PCA"
        },
        {
            name: "线性判别分析",
            nameEn: "Linear Discriminant Analysis (LDA)",
            category: "降维算法",
            desc: "有监督的线性降维方法，最大化类间距离",
            principle: "找到使类间散度与类内散度比值最大的投影方向",
            formula: "max J(w) = w'Sbw / w'Sww",
            pros: "考虑类别信息、适合分类任务",
            cons: "只能降到C-1维、假设各类协方差相同",
            applications: "人脸识别、分类预处理",
            libraries: "sklearn.discriminant_analysis.LinearDiscriminantAnalysis"
        },
        {
            name: "t-SNE",
            nameEn: "t-Distributed Stochastic Neighbor Embedding",
            category: "降维算法",
            desc: "非线性降维方法，特别适合数据可视化",
            principle: "保持高维空间中点的相对距离关系到低维空间",
            formula: "最小化高维和低维概率分布的KL散度",
            pros: "可视化效果好、保持局部结构",
            cons: "计算慢、不可逆、结果不确定",
            applications: "高维数据可视化、聚类探索",
            libraries: "sklearn.manifold.TSNE"
        },
        {
            name: "UMAP",
            nameEn: "Uniform Manifold Approximation and Projection",
            category: "降维算法",
            desc: "基于流形学习的快速降维方法",
            principle: "基于黎曼几何和代数拓扑构建高维数据的拓扑表示",
            formula: "优化模糊集的交叉熵",
            pros: "比t-SNE更快、保持全局结构更好",
            cons: "参数敏感、理论复杂",
            applications: "大规模数据可视化、聚类预处理",
            libraries: "umap.UMAP"
        },
        {
            name: "自编码器",
            nameEn: "Autoencoder",
            category: "降维算法",
            desc: "使用神经网络进行非线性降维",
            principle: "编码器压缩输入，解码器重建输入，学习中间表示",
            formula: "min ||x - Decoder(Encoder(x))||²",
            pros: "非线性降维、可学习复杂表示",
            cons: "需要大量数据、训练时间长",
            applications: "特征学习、图像压缩、去噪",
            libraries: "tensorflow.keras / pytorch"
        },

        // 深度学习
        {
            name: "多层感知机",
            nameEn: "Multi-Layer Perceptron (MLP)",
            category: "深度学习",
            desc: "最基础的全连接前馈神经网络",
            principle: "多层神经元通过非线性激活函数进行变换",
            formula: "y = f(W₃f(W₂f(W₁x + b₁) + b₂) + b₃)",
            pros: "万能近似器、灵活",
            cons: "参数多、容易过拟合",
            applications: "分类回归的基础模型",
            libraries: "sklearn.neural_network.MLPClassifier"
        },
        {
            name: "卷积神经网络",
            nameEn: "Convolutional Neural Network (CNN)",
            category: "深度学习",
            desc: "使用卷积操作提取空间特征的神经网络",
            principle: "通过卷积核在图像上滑动提取局部特征",
            formula: "特征图 = sigma(W * X + b)",
            pros: "参数共享、平移不变性、适合图像",
            cons: "需要大量数据、计算量大",
            applications: "图像分类、目标检测、人脸识别",
            libraries: "tensorflow.keras.layers.Conv2D"
        },
        {
            name: "循环神经网络",
            nameEn: "Recurrent Neural Network (RNN)",
            category: "深度学习",
            desc: "处理序列数据的神经网络",
            principle: "通过隐藏状态传递序列信息",
            formula: "h_t = f(W_hh * h_{t-1} + W_xh * x_t)",
            pros: "处理变长序列、考虑时序信息",
            cons: "梯度消失/爆炸、长期依赖问题",
            applications: "文本生成、语音识别",
            libraries: "tensorflow.keras.layers.SimpleRNN"
        },
        {
            name: "长短期记忆网络",
            nameEn: "Long Short-Term Memory (LSTM)",
            category: "深度学习",
            desc: "解决长期依赖问题的改进RNN",
            principle: "通过门控机制控制信息的遗忘和记忆",
            formula: "f_t = sigma(W_f·[h_{t-1}, x_t] + b_f)",
            pros: "解决长期依赖、避免梯度消失",
            cons: "参数多、训练较慢",
            applications: "机器翻译、情感分析、时间序列预测",
            libraries: "tensorflow.keras.layers.LSTM"
        },
        {
            name: "门控循环单元",
            nameEn: "Gated Recurrent Unit (GRU)",
            category: "深度学习",
            desc: "LSTM的简化版本，参数更少",
            principle: "使用更新门和重置门控制信息流动",
            formula: "z_t = sigma(W_z·[h_{t-1}, x_t])",
            pros: "参数比LSTM少、训练更快",
            cons: "表达能力可能略弱于LSTM",
            applications: "与LSTM类似的序列任务",
            libraries: "tensorflow.keras.layers.GRU"
        },
        {
            name: "Transformer",
            nameEn: "Transformer",
            category: "深度学习",
            desc: "基于自注意力机制的序列模型",
            principle: "使用多头自注意力机制建模序列间的依赖关系",
            formula: "Attention(Q,K,V) = softmax(QK'/sqrt(d_k))V",
            pros: "并行计算、长距离依赖、效果好",
            cons: "计算复杂度O(n²)、需要大量数据",
            applications: "NLP、机器翻译、BERT、GPT",
            libraries: "transformers / tensorflow"
        },
        {
            name: "生成对抗网络",
            nameEn: "Generative Adversarial Network (GAN)",
            category: "深度学习",
            desc: "通过对抗训练生成数据的模型",
            principle: "生成器和判别器对抗博弈，相互提升",
            formula: "min_G max_D E[log D(x)] + E[log(1-D(G(z)))]",
            pros: "生成逼真数据、无需标签",
            cons: "训练不稳定、模式崩塌",
            applications: "图像生成、图像修复、风格迁移",
            libraries: "tensorflow / pytorch"
        },
        {
            name: "变分自编码器",
            nameEn: "Variational Autoencoder (VAE)",
            category: "深度学习",
            desc: "概率生成模型，学习数据的潜在分布",
            principle: "将输入编码为潜在分布，从分布采样重建",
            formula: "ELBO = E[log p(x|z)] - KL(q(z|x)||p(z))",
            pros: "生成多样化数据、可解释潜在空间",
            cons: "生成图像可能模糊",
            applications: "图像生成、数据增强、异常检测",
            libraries: "tensorflow / pytorch"
        },
        {
            name: "图神经网络",
            nameEn: "Graph Neural Network (GNN)",
            category: "深度学习",
            desc: "处理图结构数据的神经网络",
            principle: "通过消息传递聚合邻居节点信息更新节点表示",
            formula: "h_v = UPDATE(h_v, AGGREGATE({h_u: u in N(v)}))",
            pros: "处理非欧几里得数据、捕捉结构信息",
            cons: "大规模图计算复杂、过平滑问题",
            applications: "社交网络分析、分子性质预测、推荐系统",
            libraries: "dgl / torch_geometric"
        },

        // 强化学习
        {
            name: "Q-Learning",
            nameEn: "Q-Learning",
            category: "强化学习",
            desc: "基于值函数的无模型强化学习算法",
            principle: "学习状态-动作值函数Q(s,a)，选择最大Q值的动作",
            formula: "Q(s,a) <- Q(s,a) + alpha*(r + gamma*maxQ(s',a') - Q(s,a))",
            pros: "简单、无需环境模型",
            cons: "状态空间大时不可行",
            applications: "游戏AI、简单控制任务",
            libraries: "自行实现 / stable-baselines3"
        },
        {
            name: "深度Q网络",
            nameEn: "Deep Q-Network (DQN)",
            category: "强化学习",
            desc: "使用深度神经网络近似Q函数",
            principle: "神经网络输出各动作的Q值，经验回放稳定训练",
            formula: "L = E[(r + gamma*maxQ(s',a';theta') - Q(s,a;theta))²]",
            pros: "处理高维状态空间、端到端学习",
            cons: "仅适用离散动作、训练不稳定",
            applications: "Atari游戏、视频游戏AI",
            libraries: "stable-baselines3"
        },
        {
            name: "策略梯度",
            nameEn: "Policy Gradient",
            category: "强化学习",
            desc: "直接优化策略参数的强化学习方法",
            principle: "通过梯度上升最大化期望回报",
            formula: "nabla J(theta) = E[nabla log pi(a|s;theta) * R]",
            pros: "适用连续动作空间、直接优化策略",
            cons: "高方差、样本效率低",
            applications: "机器人控制、连续控制任务",
            libraries: "stable-baselines3"
        },
        {
            name: "Actor-Critic",
            nameEn: "Actor-Critic",
            category: "强化学习",
            desc: "结合值函数和策略的强化学习方法",
            principle: "Actor学习策略，Critic评估策略的价值",
            formula: "Actor: nabla J = E[nabla log pi * A], Critic: TD误差",
            pros: "降低方差、平衡值函数和策略方法",
            cons: "两个网络需要协调训练",
            applications: "连续控制、复杂决策任务",
            libraries: "stable-baselines3"
        },
        {
            name: "近端策略优化",
            nameEn: "Proximal Policy Optimization (PPO)",
            category: "强化学习",
            desc: "限制策略更新幅度的策略梯度算法",
            principle: "通过裁剪目标函数限制策略变化幅度",
            formula: "L = min(r*A, clip(r, 1-eps, 1+eps)*A)",
            pros: "稳定、超参数少、效果好",
            cons: "样本效率中等",
            applications: "OpenAI默认算法、游戏、机器人",
            libraries: "stable-baselines3.PPO"
        },

        // 概率图模型
        {
            name: "隐马尔可夫模型",
            nameEn: "Hidden Markov Model (HMM)",
            category: "概率图模型",
            desc: "描述隐藏状态序列的概率模型",
            principle: "假设隐状态满足马尔可夫性，观测只依赖当前状态",
            formula: "P(O|lambda) = sum_Q P(O|Q,lambda)P(Q|lambda)",
            pros: "适合序列标注、有成熟算法",
            cons: "状态独立假设、状态数有限",
            applications: "语音识别、词性标注、生物序列分析",
            libraries: "hmmlearn"
        },
        {
            name: "条件随机场",
            nameEn: "Conditional Random Field (CRF)",
            category: "概率图模型",
            desc: "判别式概率图模型，用于序列标注",
            principle: "对给定观测序列，直接建模标签序列的条件概率",
            formula: "P(Y|X) = exp(sum W*f(Y,X)) / Z(X)",
            pros: "考虑上下文、避免标签偏置",
            cons: "训练时间长、特征工程",
            applications: "命名实体识别、词性标注、图像分割",
            libraries: "sklearn_crfsuite / pytorch-crf"
        },
        {
            name: "贝叶斯网络",
            nameEn: "Bayesian Network",
            category: "概率图模型",
            desc: "表示变量间条件依赖关系的有向图模型",
            principle: "用有向无环图表示变量间的因果关系",
            formula: "P(X1,...,Xn) = prod P(Xi|Parents(Xi))",
            pros: "可解释性强、处理不确定性、因果推理",
            cons: "结构学习困难、精确推理复杂",
            applications: "医疗诊断、故障检测、因果分析",
            libraries: "pgmpy"
        },

        // 优化算法
        {
            name: "梯度下降",
            nameEn: "Gradient Descent",
            category: "优化算法",
            desc: "最基础的迭代优化算法",
            principle: "沿着梯度的负方向更新参数",
            formula: "theta = theta - alpha * nabla L(theta)",
            pros: "简单、通用",
            cons: "可能陷入局部最优、收敛慢",
            applications: "几乎所有机器学习模型的训练",
            libraries: "torch.optim.SGD"
        },
        {
            name: "随机梯度下降",
            nameEn: "Stochastic Gradient Descent (SGD)",
            category: "优化算法",
            desc: "使用单个样本或小批量估计梯度",
            principle: "每次用一个或小批量样本计算梯度更新",
            formula: "theta = theta - alpha * nabla L(theta; xi)",
            pros: "计算快、有正则化效果",
            cons: "梯度噪声大、需要调学习率",
            applications: "大规模数据训练",
            libraries: "torch.optim.SGD"
        },
        {
            name: "动量法",
            nameEn: "Momentum",
            category: "优化算法",
            desc: "引入动量加速收敛的优化方法",
            principle: "累积历史梯度方向，加速相关方向的更新",
            formula: "v = beta*v - alpha*nabla L; theta = theta + v",
            pros: "加速收敛、减少震荡",
            cons: "引入额外超参数",
            applications: "深度学习训练",
            libraries: "torch.optim.SGD(momentum=0.9)"
        },
        {
            name: "Adam",
            nameEn: "Adaptive Moment Estimation",
            category: "优化算法",
            desc: "自适应学习率的优化算法",
            principle: "结合动量和RMSprop，自适应调整每个参数的学习率",
            formula: "theta = theta - alpha * m / (sqrt(v) + eps)",
            pros: "自适应学习率、收敛快、默认参数好",
            cons: "可能不收敛到最优解",
            applications: "深度学习的默认优化器",
            libraries: "torch.optim.Adam"
        },
        {
            name: "AdaGrad",
            nameEn: "Adaptive Gradient",
            category: "优化算法",
            desc: "为每个参数自适应调整学习率",
            principle: "累积历史梯度平方，频繁更新的参数学习率降低",
            formula: "theta = theta - alpha / sqrt(G + eps) * nabla L",
            pros: "适合稀疏数据、自动调节学习率",
            cons: "学习率单调递减、可能过早停止",
            applications: "NLP、稀疏特征场景",
            libraries: "torch.optim.Adagrad"
        },
        {
            name: "RMSprop",
            nameEn: "Root Mean Square Propagation",
            category: "优化算法",
            desc: "AdaGrad的改进版本，使用指数移动平均",
            principle: "用指数移动平均替代累积平方梯度",
            formula: "E[g²] = beta*E[g²] + (1-beta)*g²",
            pros: "解决AdaGrad学习率递减问题",
            cons: "需要调节衰减率",
            applications: "RNN训练",
            libraries: "torch.optim.RMSprop"
        }
    ]

    // 当前选中的分类
    property string selectedCategory: "全部"
    // 搜索关键词
    property string searchKeyword: ""
    // 当前选中的算法索引
    property int selectedAlgorithmIndex: -1

    // 过滤后的算法列表
    property var filteredAlgorithms: {
        var result = [];
        for (var i = 0; i < algorithmsData.length; i++) {
            var algo = algorithmsData[i];
            var matchCategory = (selectedCategory === "全部" || algo.category === selectedCategory);
            var matchSearch = (searchKeyword === "" || 
                algo.name.toLowerCase().indexOf(searchKeyword.toLowerCase()) >= 0 ||
                algo.nameEn.toLowerCase().indexOf(searchKeyword.toLowerCase()) >= 0 ||
                algo.desc.toLowerCase().indexOf(searchKeyword.toLowerCase()) >= 0);
            if (matchCategory && matchSearch) {
                result.push(algo);
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
                    text: "机器学习算法手书"
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
                                text: "搜索算法名称或描述..."
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
                    width: 180
                    height: 32
                    model: categories
                    onCurrentTextChanged: {
                        selectedCategory = currentText;
                        selectedAlgorithmIndex = -1;
                    }
                }
            }

            // 主内容区
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // 算法列表
                Rectangle {
                    Layout.preferredWidth: 340
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
                                    text: "算法名称"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#666"
                                    Layout.preferredWidth: 140
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

                        // 算法列表
                        ListView {
                            id: algorithmListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: filteredAlgorithms

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: algorithmListView.width
                                height: 44
                                color: selectedAlgorithmIndex === index ? "#e3f2fd" : (mouseArea.containsMouse ? "#f5f5f5" : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Column {
                                        Layout.preferredWidth: 140
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 13
                                            font.bold: selectedAlgorithmIndex === index
                                            color: selectedAlgorithmIndex === index ? "#1976d2" : "#333"
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                        Text {
                                            text: modelData.nameEn
                                            font.pixelSize: 10
                                            color: "#999"
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                    Text {
                                        text: modelData.category
                                        font.pixelSize: 11
                                        color: "#888"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: selectedAlgorithmIndex = index
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
                                text: "共 " + filteredAlgorithms.length + " 个算法"
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

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 16
                        contentHeight: detailContent.height
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: detailContent
                            width: parent.width
                            spacing: 16

                            // 未选中提示
                            Item {
                                Layout.fillWidth: true
                                height: 300
                                visible: selectedAlgorithmIndex < 0

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 12

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "\u{1F4D6}"
                                        font.pixelSize: 48
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "请从左侧列表选择一个算法"
                                        font.pixelSize: 14
                                        color: "#888"
                                    }
                                }
                            }

                            // 详情内容
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 16
                                visible: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length

                                // 算法名称和分类
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 20

                                    Column {
                                        spacing: 4

                                        Text {
                                            text: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].name : ""
                                            font.pixelSize: 24
                                            font.bold: true
                                            color: "#1976d2"
                                        }

                                        Text {
                                            text: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].nameEn : ""
                                            font.pixelSize: 13
                                            color: "#888"
                                        }
                                    }

                                    Rectangle {
                                        Layout.leftMargin: 8
                                        width: categoryTag.width + 16
                                        height: 24
                                        radius: 12
                                        color: "#e8f5e9"

                                        Text {
                                            id: categoryTag
                                            anchors.centerIn: parent
                                            text: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].category : ""
                                            font.pixelSize: 12
                                            color: "#4caf50"
                                        }
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                // 简介
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
                                        text: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].desc : ""
                                        font.pixelSize: 14
                                        color: "#555"
                                        wrapMode: Text.Wrap
                                    }
                                }

                                // 核心原理
                                DetailSection {
                                    title: "核心原理"
                                    icon: "\u{1F9E0}"
                                    content: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].principle : ""
                                    bgColor: "#fff3e0"
                                    borderColor: "#ffcc80"
                                }

                                // 关键公式
                                DetailSection {
                                    title: "关键公式"
                                    icon: "\u{1F4DD}"
                                    content: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].formula : ""
                                    bgColor: "#e3f2fd"
                                    borderColor: "#90caf9"
                                    isCode: true
                                }

                                // 优点
                                DetailSection {
                                    title: "优点"
                                    icon: "\u{2705}"
                                    content: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].pros : ""
                                    bgColor: "#e8f5e9"
                                    borderColor: "#a5d6a7"
                                }

                                // 缺点
                                DetailSection {
                                    title: "缺点"
                                    icon: "\u{26A0}"
                                    content: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].cons : ""
                                    bgColor: "#ffebee"
                                    borderColor: "#ef9a9a"
                                }

                                // 应用场景
                                DetailSection {
                                    title: "应用场景"
                                    icon: "\u{1F3AF}"
                                    content: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].applications : ""
                                    bgColor: "#f3e5f5"
                                    borderColor: "#ce93d8"
                                }

                                // 常用库
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: libContent.height + 24
                                    color: "#263238"
                                    radius: 6

                                    Column {
                                        id: libContent
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 12
                                        spacing: 4

                                        Text {
                                            text: "\u{1F4E6} 常用库"
                                            font.pixelSize: 12
                                            color: "#90a4ae"
                                        }

                                        Text {
                                            width: parent.width
                                            text: selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length ? filteredAlgorithms[selectedAlgorithmIndex].libraries : ""
                                            font.family: "Consolas"
                                            font.pixelSize: 13
                                            color: "#aed581"
                                            wrapMode: Text.Wrap
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (selectedAlgorithmIndex >= 0 && selectedAlgorithmIndex < filteredAlgorithms.length) {
                                                clipboardHelper.text = filteredAlgorithms[selectedAlgorithmIndex].libraries;
                                                clipboardHelper.selectAll();
                                                clipboardHelper.copy();
                                            }
                                        }

                                        ToolTip.visible: containsMouse
                                        ToolTip.text: "点击复制"
                                        ToolTip.delay: 500
                                    }
                                }

                                Item { height: 20 }
                            }
                        }
                    }
                }
            }
        }
    }

    // 详情区块组件
    component DetailSection: Rectangle {
        property string title: ""
        property string icon: ""
        property string content: ""
        property color bgColor: "#f5f5f5"
        property color borderColor: "#e0e0e0"
        property bool isCode: false

        Layout.fillWidth: true
        height: sectionContent.height + 24
        color: bgColor
        radius: 6
        border.color: borderColor

        Column {
            id: sectionContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 12
            spacing: 6

            Text {
                text: icon + " " + title
                font.pixelSize: 13
                font.bold: true
                color: "#555"
            }

            Text {
                width: parent.width
                text: content
                font.pixelSize: isCode ? 13 : 14
                font.family: isCode ? "Consolas" : "default"
                color: isCode ? "#1565c0" : "#666"
                wrapMode: Text.Wrap
            }
        }
    }

    // 辅助复制文本
    TextEdit {
        id: clipboardHelper
        visible: false
    }
}
