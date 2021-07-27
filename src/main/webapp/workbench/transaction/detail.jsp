<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.bjpowernode.crm.settings.domain.DicValue" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bjpowernode.crm.workbench.domain.Tran" %>
<%@ page import="com.bjpowernode.crm.utils.DateTimeUtil" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";

        Map<String,String> pMap= (Map<String, String>) application.getAttribute("pMap");
        //Set<String> key=pMap.keySet();
		//下面的一行代码中，List是有序的。allStage 表示是大阶段stage里面的小阶段对象的集合。
		List<DicValue> allStage= (List<DicValue>) application.getAttribute("stageList");

		int fenjiedian =0;//这个分界点，就算是你数据库更改了，这里的分界点也能得到你的为零的那个分界。
	                      // 前提是你从数据库取出来的阶段的顺序是排列好的。
	    for(int i=0;i<allStage.size();i++){
	    	DicValue stageSingle=allStage.get(i);//得到每一个小阶段对象stageSingle
			String possibility=pMap.get(stageSingle.getText());//这一行，别忘记写getText()！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
			if ("0".equals(possibility)){
				fenjiedian=i;
				break;
			}
		}

%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		//这个页面有已经处理好的中文的tr交易放在request域中。哪里都能用~****************************************************8·
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");



		});
//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'top',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });
//展示交易相关备注的函数
		showRemarkList()
//解决备注的修改删除图标消失的步骤：1在备注的标题后面添加上id=remarkBody 2.添加下面两段话
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})
//页面加载完毕展示交易历史。调用下面已经写好的history函数
		history();
//为备注保存按钮绑定事件
		$("#remarkBtn").click(function () {

			var content=$("#remark").val();//这里仍旧是textarea 但是因为textarea特殊，将其按照val来取值。这一点要记住
			$.ajax({
				url:"workbench/transaction/saveRemark.do",
				data:{      "noteContent":$.trim(content),
					"transactionId" :"${tr.id}"// js中使用EL表达式必须加上双引号
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/fales，"trr":{备注信息整体}
					if(data.success){
						//添加成功后，把文本域中的内容清空掉
						$("#remark").val("");

						//添加成功，在textarea上方添加一个div
						var html="";
						html += '<div id='+data.trr.id+' class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
						html += '<h5 id="e'+data.trr.id+'">'+data.trr.noteContent+'</h5>';
						//上面的e 是随便拼接的，只是为了区分id。学会这种方法。
						html += '<font color="gray">交易</font> <font color="gray">-</font> <b>${tr.customerId}-${tr.name}</b> <small style="color: gray;" id="s'+data.trr.id+'"> '+(data.trr.createTime)+' 由'+(data.trr.createBy)+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.trr.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.trr.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
						html += '</div>';
						html += '</div>';
						html += '</div>';

						$("#remarkDiv").before(html)

					}else {
						alert("添加备注失败")
					}

				}
			})
		})
//点击备注的修改图标后的更新按钮
		$("#updateRemarkBtn").click(function () {

			//这里由于下面还要使用id，所以将其放到ajax外面。若是放到ajax里面，写两遍一摸一样的显得麻烦
			var id=$("#remarkId").val();
			$.ajax({
				url:"workbench/transaction/updateRemark.do",
				data:{      "id":id,
					"noteContent":$.trim($("#noteContent").val())// 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/false,"trr":{备注信息整体}
					if(data.success){
						//修改成功，
						//根据返回来的数据，更新展现出来的备注信息。

						//下面的更新操作全部是按照已有的备注的div的内容去传值的

						//这里是展示更新后的备注信息到div
						//是给动态生成的那些div更改信息。！！！！！！！！！！！！！！！！！！！！！！！！！！！1
						$("#e"+id).html(data.trr.noteContent)//这里是对h5标签对里面的信息操作，所以使用html
						// <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
						//将上面的small里面的信息更改!!。small也是标签对!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						$("#s"+id).html(data.trr.editTime+" 由"+data.trr.editBy)

						//更改信息后，关闭模态窗口
						$("#editRemarkModal").modal("hide")


					}else {
						alert("修改备注失败")
					}


				}
			})

		})
//详细页面最上面的删除按钮
		$("#deleteBtn").click(function () {

				if(confirm("确定删除交易吗？")){
					$.ajax({
						url:"workbench/transaction/delete.do",
						data:{"id":"${tr.id}"} ,         //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
								var url=document.referrer;
								window.location.href=url;
							}else {
								alert("删除交易活动失败")
							}


						}
					})

				}


		})

	});

	function history() {
		$.ajax({
			url:"workbench/transaction/history.do",
			data:{    "tranId":"${tr.id}"                             // 这里是你传递的数据
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
				data[{交易历史1}{2}{3}]
				 */
				var html="";
				$.each(data,function (i,n) {
				  	html += '<tr>';
					html += '<td>'+n.stage+'</td>';
					html += '<td>'+n.money+'</td>';
					html += '<td>'+n.possibility+'</td>';
					html += '<td>'+n.expectedDate+'</td>';
					html += '<td>'+n.createTime+'</td>';
					html += '<td>'+n.createBy+'</td>';
					html += '</tr>';


				})
				$("#historyBody").html(html);


			}
		})

	}
//当你点击阶段的图标时，会触发这个函数。
	function changeStage(stage,i) {
		$.ajax({
			url:"workbench/transaction/changeStage.do",
			data:{  "id":"${tr.id}",//这里不是getId!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!////
			         "stage":stage,
				      "money":"${tr.money}",
				     "expectedDate":"${tr.expectedDate}"//生成交易历史的时候所使用的参数
			},
			type:"post",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
				data{"success":true/false,"tr":{交易}}
				 */
				if(data.success){
					//更改成功后，需要给界面上对应的值重新填充
					$("#stage").html(data.tr.stage);
					$("#possibility").html(data.tr.possibility);
					$("#editTime").html(data.tr.editTime);
					$("#editBy").html(data.tr.editBy);
					// var url=document.referrer;
					// window.location.href=url
					//改变图标
					changeIcon(stage,i);
				}else{
					alert("更改交易阶段失败")
				}
			}
		})
	}
//阶段变化后，重新改变阶段图标
	function changeIcon(stage,a) {
		var index=a;
		var point="<%=fenjiedian%>"//这里必须加引号。能将八大基本类型，和string直接转化为var对象

		var possibility=$("#possibility").html();//这里找的是页面上填充的可能性的值

		// alert(index)
        // alert(point)
        //alert(possibility)

		if(possibility=="0"){
			for(var i=0;i<point;i++){//i表示你即将重新布置的图标
				//alert(i)
				$("#"+i).removeClass()
				$("#"+i).addClass("glyphicon glyphicon-record mystage")
				$("#"+i).css("color","#000000") //黑圈
			}
			for(var i=point;i<<%=allStage.size()%>;i++){
				//alert(i)
				if(i==index){
					$("#"+i).removeClass()
					$("#"+i).addClass("glyphicon glyphicon-remove mystage")
					$("#"+i).css("color","#FF0000")//红叉
				}
				else {
					//alert(i)
					$("#"+i).removeClass()
					$("#"+i).addClass("glyphicon glyphicon-remove mystage")
					$("#"+i).css("color","#000000")//黑叉
				}
			}
		}

		else {
			for(var i=0;i<point;i++){
				if(i<index){
					$("#"+i).removeClass()
					$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage")
					$("#"+i).css("color","#90F790")//绿标
				}
				else if(i==index){
					$("#"+i).removeClass()
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage")
					$("#"+i).css("color","#90F790")//绿圈
				}
				else {
					$("#"+i).removeClass()
					$("#"+i).addClass("glyphicon glyphicon-record mystage")
					$("#"+i).css("color","#000000")//黑圈
				}

			}
			for(var i=point;i<<%=allStage.size()%>;i++){
				$("#"+i).removeClass()
				$("#"+i).addClass("glyphicon glyphicon-remove mystage")
				$("#"+i).css("color","#000000")//黑叉

			}



		}

	}
//展示交易相关备注的函数
	function showRemarkList() {
		$.ajax({
			url:"workbench/transaction/getRemarkListByTid.do",
			data:{       "transactionId":"${tr.id}"             //此处注意是EL表达式 。在js中使用el表达式必须加上“”  。此处的a是ActivityCOntroller类中的的detail方法的值。是一个活动对象。将其放在了request区域中          // 这里是你传递的数据!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//data
				// [{备注1} {备注2}.....]
				var html="";
				$.each(data,function (i,n) {
					html += '<div id='+n.id+' class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
					html += '<font color="gray">交易</font> <font color="gray">-</font> <b>${tr.customerId}-${tr.name}</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';
				})
				$("#remarkDiv").before(html)
			}
		})

	}
//点击备注的修改图标
	function editRemark(id) {
		//alert(id)

		//将编辑的模态窗口的隐藏域中的id进行赋值!!!!!!!!!!!这个难理解一点
		$("#remarkId").val(id);

		//找到指定的存放备注信息的h5标签
		var noteContent=$("#e"+id).html();//这行操作一定要会！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
		//将h5中展现你出来的原始信息，赋予到修改操作的模态窗口的文本域中
		$("#noteContent").val(noteContent);

		//以上信息处理完毕后，将修改备注的模态窗口打开
		$("#editRemarkModal").modal("show")
	}
//点击备注的删除图标
	function deleteRemark(id) {  //上面使用这个方法传参的时候。字符串的拼接我真的看不懂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
		//课中讲的是因为是动态生成的元素所触发的方法的参数必须套在字符串当中
		//alert(id)
		if(confirm("确认删除该备注吗？")){
			$.ajax({
				url:"workbench/transaction/deleteRemark.do",
				data:{   "id":id                              // 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					// { "success":true/false}
					if(data.success){


						//showRemarkList();
						//showRemarkList(); 这样写会导致越删除越多。因为他虽然删除了数据。
						// 但是不会清空之前已经读出来的,因为使用的是before方法
						//所以会不断增多.所以改进如下

						$("#"+id).remove();//首先在动态生成的语句中，为每个活动备注加上id。。这是一个小技巧！！！！！！！！！！！！！！！！！！！！！
						//注意这里$("#"+id)的特殊方式。表示的意思是根据每个活动备注的id
						//去找到对应div块。即活动备注。然后删除他即可



					}
					else {
						alert("删除备注失败");
					}


				}
			})

		}


	}
	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${tr.customerId}—${tr.name} <small>￥${tr.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/edit.do?id=${tr.id}';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 进到详细页面的时候的阶段图标状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%

			Tran tr= (Tran) request.getAttribute("tr");
			String currentStage=tr.getStage();

		 	String currentPb= tr.getPossibility();
			//System.out.println(currentPb+"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`");
		 	//为0
		 	if("0".equals(currentPb)){

		 		for(int i=0;i<allStage.size();i++){

					if(i<fenjiedian){

						//黑圈
		%>
		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #000000;"></span>-------------
		<%
					}
					else if (currentStage.equals(allStage.get(i).getValue())){
						//红叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')"class="glyphicon glyphicon-remove mystage"	 data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #ff0000;"></span>-------------

		<%
					}
					else{
						//黑叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #000000;"></span>-------------

		<%
					}

				}
//不为0
			}else {
		 		int currentIndex=0;
				for(int i=0;i<allStage.size();i++){
					if(currentStage.equals(allStage.get(i).getValue())){
						currentIndex=i;
						break;
					}
				}
				for(int i=0;i<allStage.size();i++){
					if(i<currentIndex){
						//绿圈
		%>
		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-ok-circle mystage" style="color: #90F790;" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #90F790;"></span>-------------

		<%
					}
					else if(i==currentIndex){
						//绿标
		%>
		<span id="<%=i%>"  onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-map-marker mystage" style="color: #90F790;" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #90F790;"></span>-------------

		<%
					}else if(i<fenjiedian){
						//黑圈
		%>

		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #000000;"></span>-------------

		<%
					}else {
						//黑叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=allStage.get(i).getValue()%>','<%=i%>')" class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="<%=allStage.get(i).getText()%>" style="color: #000000;"></span>-------------

		<%
					}

				}

			}

		%>
		<%=tr.getNextContactTime()%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>--%>
<%--		-------------%>
<%--		<span class="closingDate">2010-10-10</span>--%>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b&nbsp;>${tr.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${tr.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.customerId}—${tr.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${tr.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">&nbsp;${tr.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">&nbsp;${tr.possibility}</b></div><%--	!!!这里使用的是detail方法中的request的值。。当然这里也可以再写完hisotory后使用tr.属性!!!!!!!!!!!!!!!!!!!!!!这里使用的是!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	--%>

			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${tr.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tr.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${tr.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">&nbsp;${tr.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${tr.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${tr.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">&nbsp;联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>联系人
					&nbsp;&nbsp;${tr.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;&nbsp;${tr.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<!-- 备注1 -->
		<!-- 备注2 -->

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="remarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">

		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="historyBody">
<%--						<tr>--%>
<%--							<td>资质审查</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>10</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2016-10-10 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
<%--						<tr>--%>
<%--							<td>需求分析</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>20</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2016-10-20 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
<%--						<tr>--%>
<%--							<td>谈判/复审</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>90</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2017-02-09 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>