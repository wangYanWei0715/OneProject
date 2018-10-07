package net.xdclass.base_project.async;

import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Component;

import java.util.concurrent.Future;

/**
 * @描述: 异步执行类
 * @参数: base_project
 * @创建人: wyw
 * @时间: 2018-10-02 16:00
 **/
@Component
public class AsyncTask {


    @Async
    public void asyncTask1() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(8000L);
        long end = System.currentTimeMillis();
        System.out.println("任务2耗时"+(end-start));
    }

    @Async
    public void asyncTask3() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(2000L);
        long end = System.currentTimeMillis();
        System.out.println("任务3耗时"+(end-start));
    }

    @Async
    public void asyncTask4() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(2000L);
        long end = System.currentTimeMillis();
        System.out.println("任务4耗时"+(end-start));
    }

    @Async
    public Future<String> asyncTask5() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(4000L);
        long end = System.currentTimeMillis();
        System.out.println("任务5耗时"+(end-start));
        return new AsyncResult<String>("任务5");
    }

    @Async
    public Future<String> asyncTask6() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(4000L);
        long end = System.currentTimeMillis();
        System.out.println("任务6耗时"+(end-start));
        return new AsyncResult<String>("任务6");
    }

    @Async
    public Future<String> asyncTask7() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread.sleep(4000L);
        long end = System.currentTimeMillis();
        System.out.println("任务7耗时"+(end-start));
        return new AsyncResult<String>("任务7");
    }


}
