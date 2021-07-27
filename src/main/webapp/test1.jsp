<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
      String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
%>

<html>
<head>
      <base href="<%=basePath%>">
    <title>Title</title>
</head>
<body>

$.ajax({
url:"",
data:{
},
type:"get",
dataType: "json",                                 //这里是你想要的数据类型
success:function (data) {
}
})


var url=document.referrer;
window.location.href=url;

window.location.reload();

String createTime=DateTimeUtil.getSysTime();
String createBy=((User)request.getSession().getAttribute("user")).getName();

$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
minView: "month",
language:  'zh-CN',
format: 'yyyy-mm-dd',
autoclose: true,
todayBtn: true,
pickerPosition: "bottom-left"
});

</body>
</html>
