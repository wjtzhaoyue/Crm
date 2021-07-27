<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){

		$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
				$("#tranForm")[0].reset()
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		//为放大镜按钮注册点击事件。
		// $("#openSearchModalBtn").click(function () {       //妈的为什么我这里使用自定义的id跳转会自动退到登陆界面！！！！！！！！！！！！！
		// 	$("#searchActivityModal").modal("show")
        //
		// })

		$("#aname").keydown(function (event) {
			if(event.keyCode==13){
				$.ajax({
					url:"workbench/clue/getActivityByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
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
//重要！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
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

			//关闭模态窗口
			$("#searchActivityModal").modal("hidden")

		})

		//为转换按钮添加事件
		$("#convertBtn").click(function () {
			if($("#isCreateTransaction").prop("checked")){


				//alert("需要创建交易")
				//如果需要创建交易，不仅要上传线索id 还要上传  临时交易的一些信息。具体如下：金额，交易名称，预计成交日期，阶段，市场活动源（id)
				//window.location.href="workbench/clue/convert.do?clueId={param.id}&money=xxx&name=xxx&expectedDate=xxx&stage=xxx&actiivityId=xxx"
				//以上的方法很麻烦，而且表单一旦扩充，挂载的参数有可能超出浏览器地址栏上限
				$("#tranForm").submit()

			}
			else{
				//alert("不需要创建交易")
				//如果不需要创建交易，仅要上传线索id
				window.location.href="workbench/clue/convert.do?clueId=${param.id}"
			}


		})
	});
</script>

</head>
<body>

	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
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
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
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
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="submitActivityBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${param.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="tranForm" action="workbench/clue/convert.do" method="post">

			<input type="hidden" name="clueId" value="${param.id}"> <%--后期加上的，注意这里的思想！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！--%>
			<input type="hidden" name="flag" value="a">
<%----%>

		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<option></option>
				<c:forEach items="${stageList}" var="s">
					<%--		 value ,text是此处字典七大类型中每一大类的值。是数据库中的列名--%>
					<option value="${s.value}">${s.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activityName">市场活动源&nbsp;&nbsp;<a href="#"  id="openSearchModalBtn" data-toggle="modal" data-target="#searchActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activityName" placeholder="点击上面搜索" readonly>

			  <input type="hidden" id="activityId" >

			  <%--	隐藏域id，传活动的id，  放的位置，我才可以随意。只要合适即可，不一定非要在这里。为后面的交易表的信息做补充	--%>
		  </div>
		</form>
<%--		--%>
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" id="convertBtn" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>