package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {

    Customer getCustomerByName(String company);

    int save(Customer cus);

    List<String> getCustomerName(String name);

    int getTotalByCondition(Map<String, Object> map);

    List<Customer> getCustomerListByCondition(Map<String, Object> map);

    Customer getCustomerById(String id);

    int update(Customer customer);

    Customer getDetailCustomerByIdDetail(String id);

    int getCountByIds(String[] ids);

    int delete(String[] ids);
}
