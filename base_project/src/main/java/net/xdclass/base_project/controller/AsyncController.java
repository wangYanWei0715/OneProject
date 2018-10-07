package net.xdclass.base_project.controller;

import net.xdclass.base_project.async.AsyncTask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.Future;

/**
 * @描述: 异步任务
 * @参数: base_project
 * @创建人: wyw
 * @时间: 2018-10-02 16:05
 **/
@RequestMapping(value = "/test/v1/aysnc")
@RestController
public class AsyncController {

    @Autowired
    private AsyncTask asyncTask;

    @RequestMapping(value = "/aysnctask1")
    public void task1(){
        /*try {
            asyncTask.asyncTask1();

            asyncTask.asyncTask3();

            asyncTask.asyncTask4();

            asyncTask.asyncTask5();
        }catch (Exception e){
            e.printStackTrace();
        }*/
        long start = System.currentTimeMillis();
        try {
            Future<String> stringFuture = asyncTask.asyncTask5();
            Future<String> stringFuture1 = asyncTask.asyncTask6();
            Future<String> stringFuture2 = asyncTask.asyncTask7();
            for (;;){
                if (stringFuture.isDone() && stringFuture1.isDone() && stringFuture2.isDone()){
                    break;
                }
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        long end = System.currentTimeMillis();
        System.out.println("总耗时："+(end-start));

    }

}
