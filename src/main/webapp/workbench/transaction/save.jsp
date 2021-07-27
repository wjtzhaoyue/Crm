<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
	Map<String,String> pMap= (Map<String, String>) application.getAttribute("pMap");
	Set<String> set=pMap.keySet();
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

	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">
<%--		！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1--%>
<%--  	拼接json。--%>
			var json={
				<%
				 for(String key :set){
				 	 String value=pMap.get(key);
				%>

				"<%=key%>":<%=value%>,//这里最后一个，逗号会自动处理掉。因为我们上来就定义了var json。来提示这是一个json对象

				<%
				}
				%>

			};
			//alert(json)


		$(function () {
			//自动补全
			$("#create-customerName").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
							{ "name" : query },
							function (data) {
								//alert(data);
								//data[{客户名字1}{2}{3}...]


								process(data);
							},
							"json"
					);
				},
				delay: 100//延迟加载时间,单位毫秒
			});

			$(".time1").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			$(".time2").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			// $("#openSearchActivityModalBtn").click(function () {  //人家按钮已经设置了 会自动打开，所以我们不用手动打开了
			// 	$("#findMarketActivity").modal("show")
			//
			// })

			$("#aname").keydown(function (event) {
				if(event.keyCode==13){
					$.ajax({
						url:"workbench/transaction/getActivityByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
						data:{
							"aname":$.trim($("#aname").val())

						},
						type:"get",
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data[{活动1}{2}{3}]
                            因为这里是铺表，所以不能去判断success。是必须成功的事情。
                             */
							var html=""

							$.each(data,function (i,n) {

								html += '<tr>'
								html += '<td><input type="radio"   value="'+n.id+'"  name="xz" /></td>'//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
								html += '<td id="'+n.id+'">'+n.name+'</td>'
								html += '<td>'+n.startDate+'</td>'
								html += '<td>'+n.endDate+'</td>'
								html += '<td>'+n.owner+'</td>'
								html += '</tr>'
							})

							$("#activitySearchBody").html(html)

						}
					})
					return false;
				}


			})

			$("#submitActivityBtn").click(function () {

				//将活动的id放到隐藏区域中
				var  $xz= $("input[name=xz]:checked")
				var  id=$xz.val()//这里取得是 value的值
				//点击活动的提交按钮，将市场活动的名字文本值铺上
				var  name=$("#"+id).html()//html取的是标签对中的值
				//alert(name)
				$("#activityName").val(name)

				//alert(id)
				$("#activityId").val(id)

				//关闭模态窗口.....!!!!这里可以不写!.因为  data-dismiss="modal"!   点击这个按钮后，按钮里面自动写了这个关闭 !!!!!!!!!!!!!!!!!!!!!!!!!!!
				//$("#findMarketActivity").modal("hidden");

			})


			// $("#openSearchContactsModalBtn").click(function () {
			// 	$("#findContacts").modal("show")
			//
			// })


			$("#cname").keydown(function (event) {
				if(event.keyCode==13){
					$.ajax({
						url:"workbench/transaction/getContactsByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
						data:{
							"cname":$.trim($("#cname").val())

						},
						type:"get",
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data[{联系人1}{2}{3}]
                            因为这里是铺表，所以不能去判断success。是必须成功的事情。
                             */
							var html=""

							$.each(data,function (i,n) {
							html += '<tr>'
							html += '<td><input type="radio" value="'+n.id+'" name="xz"/></td>'
							html += '<td id="'+n.id+'">'+n.fullname+'</td>'
							html += '<td>'+n.email+'</td>'
							html += '<td>'+n.mphone+'</td>'
							html += '</tr>'


							})

							$("#contactsSearchBody").html(html)

						}
					})
					return false;
				}


			})

			$("#submitContactsBtn").click(function () {

				//将活动的id放到隐藏区域中
				var  $xz= $("input[name=xz]:checked")
				var  id=$xz.val()//这里取得是 value的值
				//点击活动的提交按钮，将市场活动的名字文本值铺上
				var  name=$("#"+id).html()//html取的是标签对中的值
				//alert(name)
				$("#contactsName").val(name)

				//alert(id)
				$("#contactsId").val(id)

				//关闭模态窗口.....!!!!这里可以不写!.因为  data-dismiss="modal"!   点击这个按钮后，按钮里面自动写了这个关闭 !!!!!!!!!!!!!!!!!!!!!!!!!!!
				//$("#findMarketActivity").modal("hidden");

			})

			//为阶段的下拉框添加点击事件(需要记忆！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！)
			$("#create-stage").change(function () {//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				//var stage=this.val().这句话这么写也可以，只不过使用this可读性差了一点
				var  stage=$("#create-stage").val();
				//alert(stage)
				/*该填写可能性了。但是pMap中的是java语言。现在我们这里是js
				pMap的内容如下：
				pMap("01资质审查":10)
				pMap("02需求分析":25)
				所以将pMap中的数据转化为json'
				 */
               //alert(stage)
				var  possibility =json[stage];//json.key的形式在此处行不通
				//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111111！！！！！！1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
				//但是这里的stage是动态变化的。不能使用json.key的形式。所以我们这里使用的方式要换为json[]
				//alert(possibility)
                 $("#create-possibility").val(possibility);

			})

			$("#saveBtn").click(function () {
				$("#tranForm").submit();

			})


		});
	</script>
</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="aname" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary"  data-dismiss="modal" id="submitActivityBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="cname" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsSearchBody">
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>李四</td>--%>
<%--								<td>lisi@bjpowernode.com</td>--%>
<%--								<td>12345678901</td>--%>
<%--							</tr>--%>
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>李四</td>--%>
<%--								<td>lisi@bjpowernode.com</td>--%>
<%--								<td>12345678901</td>--%>
<%--							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="submitContactsBtn">提交</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>

	<form  action="workbench/transaction/save.do" id="tranForm" method="post" class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner" name="owner">
				 <option></option>
					<c:forEach items="${uList}" var="u">
						<option value="${u.id}" ${user.id eq u.id ? "selected" : ""}>${u.name}</option>
<%--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11                                  --%>
					</c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label" >金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName" name="name">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time1" id="create-expectedClosingDate" name="expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-customerName" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>

			<label for="create-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-stage" name="stage">
			  	<option></option>
			  <c:forEach items="${stageList}" var="s">
				  <option value="${s.value}">${s.text}</option>
			  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType" name="type">
				  <option></option>
					<c:forEach items="${transactionTypeList}" var="t">
						<option value="${t.value}">${t.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" ><%--	可能性不用提交！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！	--%>
			</div>
		</div>
<%--		--%>
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource" name="source">
				  <option></option>
					<c:forEach items="${sourceList}" var="s">
						<option value="${s.value}">${s.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="activityName" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="#" id="openSearchActivityModalBtn" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="activityName"  placeholder="点击放大镜搜索" readonly><%--这一行的id是用来被定位到，然后被赋予文本值的		--%>
				<input type="hidden" id="activityId"  name="activityId"> <%--	是提交这里的隐藏域！
				                                              因为数据库需要的就是id而不是你输入的中文。
				                                              隐藏域的value的值会在你选择好市场活动源之后。给value赋值为活动的id
				                                               而且我们需要的就是市场活动源的id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！	--%>
			</div>
		</div>
<%--		--%>
		<div class="form-group">
			<label for="contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="#" id="openSearchContactsModalBtn"  data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="contactsName" placeholder="点击放大镜搜索" readonly>
				<input type="hidden" id="contactsId" name="contactsId" ><%--	是提交这里的隐藏域	--%>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe" name="description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time2" id="create-nextContactTime" name="nextContactTime">
			</div>
		</div>
		
	</form>
</body>
</html>