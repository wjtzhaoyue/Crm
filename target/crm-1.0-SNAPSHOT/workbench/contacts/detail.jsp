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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">
<%--	这个页面永远在request域有联系人对象c。owner什么的都已经处理为中文了--%>
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

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
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
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})
		//全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
															  //input且name=xz的标签赋值为checked

		})
		$("#activitySearchBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		})

		showRemarkList();
		//为保存按钮添加操作
		$("#remarkBtn").click(function () {

			var content=$("#remark").val();//这里仍旧是textarea 但是因为textarea特殊，将其按照val来取值。这一点要记住
			$.ajax({
				url:"workbench/contacts/saveRemark.do",
				data:{      "noteContent":$.trim(content),
					"contactsId" :"${c.id}"// js中使用EL表达式必须加上双引号
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/fales，"cr":{备注信息整体}
					if(data.success){
						//添加成功后，把文本域中的内容清空掉
						$("#remark").val("");

						//添加成功，在textarea上方添加一个div
						var html="";
						html += '<div id='+data.cr.id+' class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
						html += '<h5 id="e'+data.cr.id+'">'+data.cr.noteContent+'</h5>';
						//上面的e 是随便拼接的，只是为了区分id。学会这种方法。
						html += '<font color="gray">联系人</font> <font color="gray">-</font> <b>${c.fullname}${c.appellation}-${c.customerId}</b> <small style="color: gray;" id="s'+data.cr.id+'"> '+(data.cr.createTime)+' 由'+(data.cr.createBy)+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
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
				url:"workbench/contacts/updateRemark.do",
				data:{      "id":id,
					"noteContent":$.trim($("#noteContent").val())// 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/false,"cr":{备注信息整体}
					if(data.success){
						//修改成功，
						//根据返回来的数据，更新展现出来的备注信息。

						//下面的更新操作全部是按照已有的备注的div的内容去传值的

						//这里是展示更新后的备注信息到div
						//是给动态生成的那些div更改信息。！！！！！！！！！！！！！！！！！！！！！！！！！！！1
						$("#e"+id).html(data.cr.noteContent)//这里是对h5标签对里面的信息操作，所以使用html
						// <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
						//将上面的small里面的信息更改!!。small也是标签对!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						$("#s"+id).html(data.cr.editTime+" 由"+data.cr.editBy)

						//更改信息后，关闭模态窗口
						$("#editRemarkModal").modal("hide")


					}else {
						alert("修改备注失败")
					}


				}
			})

		})

		showTranList();
		showActivityList()
		$("#aname").keydown(function (event) {
			if(event.keyCode==13){
				$.ajax({
					url:"workbench/contacts/getActivityByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
					data:{
						"aname":$.trim($("#aname").val()),


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
							html += '<td><input type="checkbox"   value="'+n.id+'"  name="xz" /></td>'//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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

		$("#guanlianBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择需要关联的记录")
			}else {
					var param=""
					for(var i=0 ;i<$xz.length;i++){
						param += "id="+$($xz[i]).val() // 这里的$$有两个.第一个表示将jquery数组中的单个（即dom对象）转换为jquery对象。
						// 这样才能使用val（）。这里还可以写作$xz[i].value
						if(i<$xz.length-1){
							param += "&";       //这里拼接的是地址栏的参数。因为是参数。所以地址栏会自动在第一个参数前添加”？“
						}
					}
					param += "&cid=${c.id}"
					//alert(param)
					$.ajax({
						url:"workbench/contacts/guanlian.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false,"aList":[{活动1}{活动2}{3}]}
                             */
							if(data.success){
								var  html="";
								$.each(data.aList,function (i,n) {
									html += '<tr id="'+n.id+'">';
									html += '<td><a href="activity/detail.jsp" style="text-decoration: none;">'+n.name+'</a></td>';
									html += '<td>'+n.startDate+'</td>';
									html += '<td>'+n.endDate+'</td>';
									html += '<td>'+n.owner+'</td>';
									html += '<td><a href="#" data-toggle="modal" onclick="Unbind1(\''+n.id+'\')" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
									html += '</tr>';

								})
								$("#activityBody").append(html);
							}
							else {
								alert("关联失败")
							}





						}
					})



			}
		})
		$("#updateBtn").click(function () {

			$.ajax({
				url:"workbench/contacts/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"source":$.trim($("#edit-source").val()),
					"fullname":$.trim($("#edit-fullname").val()),
					"appellation":$.trim($("#edit-appellation").val()),
					"job":$.trim($("#edit-job").val()),
					"mphone":$.trim($("#edit-mphone").val()),
					"email":$.trim($("#edit-email").val()),
					"birth":$.trim($("#edit-birth").val()),

					"customerName":$.trim($("#edit-customerName").val()),

					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val())
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){
						window.location.reload();

						// pageList(1,2)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
						//$("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，再次打开添加的时候能清空窗口。
						$("#editContactsModal").modal("hide")
					}
					else {
						alert("修改联系人失败");
					}
				}
			})




		})

	});

	//函数
function showRemarkList() {
	$.ajax({
		url:"workbench/contacts/getRemarkListByCid.do",
		data:{       "contactsId":"${c.id}"             //此处注意是EL表达式 。在js中使用el表达式必须加上“”  。此处的a是ActivityCOntroller类中的的detail方法的值。是一个活动对象。将其放在了request区域中          // 这里是你传递的数据!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		},
		type:"get",
		dataType: "json",                                 //这里是你想要的数据类型
		success:function (data) {
			var html="";
			$.each(data,function (i,n) {
				html += '<div id='+n.id+' class="remarkDiv" style="height: 60px;">';
				html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
				html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
				//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
				html += '<font color="gray">联系人</font> <font color="gray">-</font> <b>${c.fullname}${c.appellation}-${c.customerId}</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
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
function deleteRemark(id) {  //上面使用这个方法传参的时候。字符串的拼接我真的看不懂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
	//课中讲的是因为是动态生成的元素所触发的方法的参数必须套在字符串当中
	//alert(id)
	if(confirm("确认删除该备注吗？")){
		$.ajax({
			url:"workbench/contacts/deleteRemark.do",
			data:{   "id":id                              // 这里是你传递的数据
			},
			type:"post",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//data
				// { "success":true/false}
				if(data.success){



					$("#"+id).remove();//首先在动态生成的语句中，为每个活动备注加上id。。这是一个小技巧！！！！！！！！！！！！！！！！！！！！！



				}
				else {
					alert("删除备注失败");
				}


			}
		})

	}
}
//展示所有交易
function showTranList() {
	$.ajax({
		url:"workbench/contacts/getTranListByCid.do",
		data:{"id":"${c.id}"
		},
		type:"get",
		dataType: "json",                                 //这里是你想要的数据类型
		success:function (data) {
			/*
            data[{交易1}{2}{3}]
             */
			var  html="";
			$.each(data,function (i,n) {
				html += '<tr id="'+n.id+'">';
				html += '<td><a href="workbench/transaction/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.customerId+'-'+n.name+'</a></td>';
				html += '<td>'+n.money+'</td>';
				html += '<td>'+n.stage+'</td>';
				html += '<td>'+json[n.stage]+'</td>';
				html += '<td>'+n.expectedDate+'</td>';
				html += '<td>'+n.type+'</td>';
				html += '<td><a href="#" onclick="deleteTran1(\''+n.id+'\')"  data-toggle="modal" data-target="#removeTransactionModal"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
				html += '</tr>';
			})
			$("#tranBody").html(html);
		}
	})


}
//用来转换交易id的
function deleteTran1(id) {
	//lert(id)
	$("#shanchujiaoyiId").val(id);

}
//删除交易.
function deleteTran(id) {

	$.ajax({
		url:"workbench/contacts/deleteTran.do",
		data:{"id":id},
		type:"post",     //删除操作，使用post
		dataType: "json",                                 //这里是你想要的数据类型
		success:function (data) {
			/*
            data
            {"success":true/false}
             */
			if(data.success){
				//
				$("#"+id).remove();

			}else {
				alert("删除交易失败")
			}


		}
	})



}

function showActivityList() {
	$.ajax({
		url:"workbench/contacts/getActivityListByCid.do",
		data:{"id":"${c.id}"
		},
		type:"get",
		dataType: "json",                                 //这里是你想要的数据类型
		success:function (data) {
			var  html="";
			$.each(data,function (i,n) {
				html += '<tr id="'+n.id+'">';
				html += '<td><a href="activity/detail.jsp" style="text-decoration: none;">'+n.name+'</a></td>';
				html += '<td>'+n.startDate+'</td>';
				html += '<td>'+n.endDate+'</td>';
				html += '<td>'+n.owner+'</td>';
				html += '<td><a href="#" data-toggle="modal" onclick="Unbind1(\''+n.id+'\')" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
				html += '</tr>';

			})
			$("#activityBody").html(html);


		}
	})

}
function Unbind1(id) {
	$("#jiechujiaoyiId").val(id);
}
function Unbind(id) {
	$.ajax({
		url:"workbench/contacts/Unbind.do",
		data:{"id":id},
		type:"post",     //删除操作，使用post
		dataType: "json",                                 //这里是你想要的数据类型
		success:function (data) {
			/*
            data
            {"success":true/false}
             */
			if(data.success){
				//
				$("#"+id).remove();

			}else {
				alert("解除联系人与活动的关系失败")
			}


		}
	})


}
function bianji(id) {//这里面的方法使用的是从修改哪里拿过来的。只是稍微修改了一下
	//alert(id)
	$.ajax({
		url:"workbench/contacts/getUserListAndContacts.do",
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
            {"uList":[{用户1}，{2}，{3}]，"c":{一个联系人}}
            */
			var html="<option></option>";

			$.each(data.uList,function (i,n) {
				if(data.c.owner==n.id){
					html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"
				}
				else
					html += " <option value='"+n.id+"'>"+n.name+"</option>"
			})
			$("#edit-owner").html(html);
			$("#edit-id").val(id) //这个是从后台传递回来的id！！！！！！！！！！！！！！
			$("#edit-source").val(data.c.source)
			$("#edit-fullname").val(data.c.fullname)
			$("#edit-appellation").val(data.c.appellation)
			$("#edit-job").val(data.c.job)
			$("#edit-mphone").val(data.c.mphone)
			$("#edit-email").val(data.c.email)
			$("#edit-birth").val(data.c.birth)
			$("#edit-customerName").val(data.c.customerId)
			$("#edit-description").val(data.c.description)
			$("#edit-contactSummary").val(data.c.contactSummary)
			$("#edit-nextContactTime").val(data.c.nextContactTime)
			$("#edit-address").val(data.c.address)

			//所有的东西都写好后，显示出来模态窗口
			$("#editContactsModal").modal("show")

		}
	})
}
function shanchu(id) {
	if(confirm("确定删除选中的联系人吗？")){


		$.ajax({
			url:"workbench/contacts/delete.do",
			data:{"id":id},          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
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
					alert("删除联系人失败")
				}


			}
		})

	}
}

	
</script>

</head>
<body>

	<!-- 解除联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="unbundActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">解除关联</h4>
				</div>
				<div class="modal-body">
					<p>您确定要解除该关联关系吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" onclick="Unbind($('#jiechujiaoyiId').val())" data-dismiss="modal">解除</button>
				</div>
				<input type="hidden" id="jiechujiaoyiId">
			</div>
		</div>
	</div>
	<!-- 删除交易的模态窗口 -->
	<div class="modal fade" id="removeTransactionModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除交易</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该交易吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" onclick="deleteTran($('#shanchujiaoyiId').val())" data-dismiss="modal">删除</button>
				</div>
				<input type="hidden" id="shanchujiaoyiId">
			</div>
		</div>
	</div>
	
	<!-- 联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="bundActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="aname" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable2" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="qx"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="guanlianBtn">关联</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id">

						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
							<label for="edit-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.text}">${s.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" >
							</div>
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
									<c:forEach items="${appellationList}" var="a">
										<option value="${a.text}">${a.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" >
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" >
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-birth">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal"  id="updateBtn">更新</button>
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
			<h3>&nbsp;${c.owner}${c.appellation} <small> - ${c.customerId}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default"onclick="bianji('${c.id}')"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" onclick="shanchu('${c.id}')"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.owner}${c.appellation}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.job}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">生日</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;&nbsp;${c.birth}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;&nbsp;${c.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;&nbsp;${c.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 90px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${c.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	<!-- 备注 -->
	<div style="position: relative; top: 20px; left: 40px;" id="remarkBody">
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
					<h4 class="modal-title" id="myModalLabelq">修改备注</h4>
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
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable3" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranBody">

					</tbody>
				</table>
			</div>
			
			<div>
				<a href="workbench/transaction/add.do" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">
<%--						<tr>--%>
<%--							<td><a href="activity/detail.jsp" style="text-decoration: none;">发传单</a></td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>--%>
<%--						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div >
				<a href="javascript:void(0);" data-toggle="modal" data-target="#bundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>