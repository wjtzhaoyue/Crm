<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>


<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){

		$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});


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

		showRemarkList();

		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})


		//为保存按钮添加操作
		$("#remarkBtn").click(function () {

			var content=$("#remark").val();//这里仍旧是textarea 但是因为textarea特殊，将其按照val来取值。这一点要记住
			$.ajax({
				url:"workbench/activity/saveRemark.do",
				data:{      "noteContent":$.trim(content),
					        "activityId" :"${a.id}"// js中使用EL表达式必须加上双引号
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/fales，"ar":{备注信息整体}
					if(data.success){
						//添加成功后，把文本域中的内容清空掉
						$("#remark").val("");

						//添加成功，在textarea上方添加一个div
						    var html="";
							html += '<div id='+data.ar.id+' class="remarkDiv" style="height: 60px;">';
							html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
							html += '<h5 id="e'+data.ar.id+'">'+data.ar.noteContent+'</h5>';
							//上面的e 是随便拼接的，只是为了区分id。学会这种方法。
							html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${a.name}</b> <small style="color: gray;" id="s'+data.ar.id+'"> '+(data.ar.createTime)+' 由'+(data.ar.createBy)+'</small>';
							html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
							html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
							html += '&nbsp;&nbsp;&nbsp;&nbsp;';
							html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
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


		$("#updateRemarkBtn").click(function () {
			//这里由于下面还要使用id，所以将其放到ajax外面。若是放到ajax里面，写两遍一摸一样的显得麻烦
			var id=$("#remarkId").val();
			$.ajax({
				url:"workbench/activity/updateRemark.do",
				data:{
					"id":id,
					"noteContent":$.trim($("#noteContent").val())// 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/false,"ar":{备注信息整体}}
					if(data.success){
						//修改成功，
						//根据返回来的数据，更新展现出来的备注信息。

						//下面的更新操作全部是按照已有的备注的div的内容去传值的

						//这里是展示更新后的备注信息到div
						//是给动态生成的那些div更改信息。！！！！！！！！！！！！！！！！！！！！！！！！！！！1
						$("#e"+id).html(data.ar.noteContent)//这里是对h5标签对里面的信息操作，所以使用html
						// <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
						//将上面的small里面的信息更改!!。small也是标签对!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						$("#s"+id).html(data.ar.editTime+" 由"+data.ar.editBy)

						//更改信息后，关闭模态窗口
						$("#editRemarkModal").modal("hide")


					}else {
						alert("修改备注失败")
					}


				}
			})

		})

//市场活动详细页面上，编辑按钮点击后 的更新按钮
		$("#updateBtn").click(function () {

			$.ajax({
				url:"workbench/activity/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"name":$.trim($("#edit-name").val()),
					"startDate":$.trim($("#edit-startDate").val()),
					"endDate":$.trim($("#edit-endDate").val()),
					"cost":$.trim($("#edit-cost").val()),
					"description":$.trim($("#edit-description").val())
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){

						window.location.reload();


					}
					else {
						alert("修改市场活动失败");
					}
				}
			})




		})

	});
//市场活动详细页面的 “编辑”  按钮
	function bianji(id) {//这里面的方法使用的是从修改哪里拿过来的。只是稍微修改了一下
		//alert(id)
		$.ajax({
			url:"workbench/activity/getUserListAndActivity.do",
			data:{
				"id":id,                           // 传递过去的被选中的活动的id!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
                data
                用户对象
                市场活动列表
                {"uList":[{用户1}，{2}，{3}]，"a":{一条市场活动}}
                */



				var html="<option></option>";

				$.each(data.uList,function (i,n) {
					if(data.a.owner==n.id){
						html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"

					}
					else
						html += " <option value='"+n.id+"'>"+n.name+"</option>"
				})
				$("#edit-owner").html(html);
				$("#edit-id").val(data.a.id) //这个是从后台传递回来的id！！！！！！！！！！！！！！
				$("#edit-name").val(data.a.name)
				$("#edit-startDate").val(data.a.startDate)
				$("#edit-endDate").val(data.a.endDate)
				$("#edit-cost").val(data.a.cost)
				$("#edit-description").val(data.a.description)

				//所有的东西都写好后，显示出来模态窗口
				$("#editActivityModal").modal("show")

			}
		})
	}

	function shanchu(id) {
		if(confirm("确定要删除吗？")){
			var param="id="+id;
			$.ajax({
				url:"workbench/activity/delete.do",
				data:param,
				type:"post",     //删除操作，使用post
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
                    data
                    {"success":true/false}
                     */
					if(data.success){
						// $.ajax({
						// 	url:"workbench/activity/shuaxin.do",
						//
						// 	type:"get",
						// 	dataType: "json",                                 //这里是你想要的数据类型
						//
						// })
						<%--					<jsp:forward page="/workbench/activity/index.jsp"></jsp:forward>--%>
						//history.back();
						//window.location.reload();
						var url=document.referrer;
						window.location.href=url;

					}else {
						alert("删除市场活动失败")
					}


				}
			})
		}
	}

	//这个是最难的！！比较难以理解这个参数id！！！！！！！！！！！！！！！！！！！！
	//这里使用 不从后台拿到需要的备注信息。而是直接从输入的文本框里拿到数据。
	//其实理应从后台拿到数据
	function editRemark(id) {
		//alert(id)

		//将编辑的模态窗口的隐藏域中的id进行赋值!!!!!!!!!!!这个难理解一点
		$("#remarkId").val(id);

		//找到指定的存放备注信息的h5标签
		var noteContent=$("#e"+id).html();//这行操作一定要会！！！！！！！！！！
		//将h5中展现出来的原始信息，赋予到修改操作的模态窗口的文本域中
		$("#noteContent").val(noteContent);

  //以上信息处理完毕后，将修改备注的模态窗口打开
		$("#editRemarkModal").modal("show")
	}

	function showRemarkList() {
		$.ajax({
			url:"workbench/activity/getRemarkListByAid.do",
			data:{       "activityId":"${a.id}"             //此处注意是EL表达式 。在js中使用el表达式必须加上“”  。此处的a是ActivityCOntroller类中的的detail方法的值。是一个活动对象。将其放在了request区域中          // 这里是你传递的数据!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//data
				// [{备注1} {备注2}.....]
				var html="";

				$.each(data,function (i,n) {
					//关于字符串拼接。因为最原本的里面用的“”双引号比较多，所以在拼接的时候选择在最外面添加单引号
					//下面的这个  $ {a.name} 是从request区域中获得的。.请求转发的区域中
					//

				html += '<div id='+n.id+' class="remarkDiv" style="height: 60px;">';
				html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
				html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
				//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
				html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${a.name}</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
				html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
				html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
				html += '&nbsp;&nbsp;&nbsp;&nbsp;';
				html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
				 //javascript:void(0) 表示禁止使用超链接
					/*
					之所以是在动态生成的图标中绑定click方法，是因为。若是我们使用id的方式，因为是动态生成的。这样的话，
					每个市场活动的评论的id都一样了。导致删除的时候会出错。


					*/
				html += '</div>';
				html += '</div>';
				html += '</div>';
				})

				//下面使用的before 是在思考之后使用的
				/*
				思考如下：如果直接在 ”大备注”上添加id，然后使用html。那么会覆盖掉“大备注” 。之前都是这么做的，
				         那是因为里面都是空的，不存在覆盖的情况。
				所以做法有两种。1. 是在“大备注”下面写一个空的div，然后使用id和html。这样就不会覆盖掉大备注
				               2. 使用append或者before。此处的做法是使用了before
				 */
				$("#remarkDiv").before(html)



			}
		})

	}

	function deleteRemark(id) {  //上面使用这个方法传参的时候。字符串的拼接我真的看不懂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
		                      //课中讲的是因为是动态生成的元素所触发的方法的参数必须套在字符串当中
		//alert(id)
		if(confirm("确认删除该备注吗？")){
			$.ajax({
				url:"workbench/activity/deleteRemark.do",
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

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 85%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
			</div>
			<div class="modal-body">

				<form class="form-horizontal" role="form">

					<input type="hidden" id="edit-id">  <%--        这行是自己添加的id--%>

					<div class="form-group">
						<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-owner">

							</select>
						</div>
						<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-name" value="发传单">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control time" id="edit-startDate" readonly  >
						</div>
						<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control time" id="edit-endDate" readonly >
						</div>
					</div>

					<div class="form-group">
						<label for="edit-cost" class="col-sm-2 control-label">成本</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-cost" value="5,000">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-description" class="col-sm-2 control-label">描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<%--
                                    关于文本域textarea：
                                    （1）一定是要以标签对。不能省略写/的形式来呈现，正常情况下标签对要紧紧挨着
                                   （2） textarea虽然是以标签对的形式存在，但是处理的时候按照表单元素。像input
                                      那样来操作，即使textarea没有value值。
                                      （3）取值的时候统一使用的是val（），而不是html()
                                    --%>
							<textarea class="form-control" rows="3" id="edit-description"></textarea>
						</div>
					</div>

				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" data-dismiss="modal" id="updateBtn">更新</button>
			</div>
		</div>
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
	



	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${a.name} <small>&nbsp;${a.startDate}~${a.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="bianji('${a.id}')" ><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" onclick="shanchu('${a.id}')"  ><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${a.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${a.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${a.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${a.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${a.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${a.createBy}</b><small style="font-size: 10px; color: gray;">  ${a.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${a.editBy}</b><small style="font-size: 10px; color: gray;">  ${a.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${a.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>哎呦！</h5>--%>
<%--				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>
<%--		--%>
<%--		<!-- 备注2 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>呵呵！</h5>--%>
<%--				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>

		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea><%-- 这行的id=remark 中的remark不能去改动，因为。remark这里有动画效果。一旦你改动就没有的动画效果了。这里的动画效果指的是。移动到添加备注的文本区域上，会自己展现”取消 删除的按钮“--%>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="remarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>
<%----%>