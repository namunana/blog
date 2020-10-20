---
title: SpringBoot常用的安全框架（一）：SpringSecurity
url: springsecurity_utl
tags:
 - SpringBoot
categories:
 - SpringBoot
 data: 2020-10-20 19: 00
---

# SpringBoot常用的安全框架（一）：SpringSecurity

_SpringSecurity和Shiro都是web后端的一种可定制的安全框架，都可以实现认证和权限控制，对于大型复杂的项目来说，这两种框架是不二之选。_

<!--more-->
**此次演示的框架是基于SpringBoot，ssm请自行跳过**

## SpringSecurity

_springsecurity最主要的两个目标是**认证**（Authentication）和**授权**（Authorization）_

**先介绍搭建的整体思路：**

1. 自定义Security(通过@EnableWebSecurity注解开启WebSecurity模式)

2. 继承WebSecurityConfigureAdapter，重写两个方法【configure(HttpSecurity http)和configure(AuthenticationManagerBuilder auth)】，这两个方法分别是做权限和认证的。

通过以上两步就可以实现认证和授权功能了，简直不要太so easy，接下来就是入门演示了

### 环境搭建
1. 做任何项目的第一步，导入项目需要的依赖

主要引入的包是security、thymeleaf模板、thymeleaf和security的整合包（这个后面要用到）

```java
<dependencies>
        <!--thymeleaf-securty-->
        <dependency>
            <groupId>org.thymeleaf.extras</groupId>
            <artifactId>thymeleaf-extras-springsecurity5</artifactId>
            <version>3.0.4.RELEASE</version>
        </dependency>

        <!--security-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!--thymeleaf-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>

        <!--web启动包-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
            <exclusions>
                <exclusion>
                    <groupId>org.junit.vintage</groupId>
                    <artifactId>junit-vintage-engine</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
```
2. 导入静态资源

{% img/images/write/security/constructor.PNG %}

3. 编写一个简单的Controller

测试项目能不能跑通

```java
package com.gdpi.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class RouterController {

    @RequestMapping({"/","/index"})
    public String index(){
        return "index";
    }

    @RequestMapping("/toLogin")
    public String toLogin(){
        return "views/login";
    }

    @RequestMapping("/level1/{id}")
    public String level1(@PathVariable("id") int id){
        return "views/level1/"+id;
    }

    @RequestMapping("/level2/{id}")
    public String level2(@PathVariable("id") int id){
        return "views/level2/"+id;
    }

    @RequestMapping("/level3/{id}")
    public String level3(@PathVariable("id") int id){
        return "views/level3/"+id;
    }
}
```

4. 关闭模板引擎的缓存，方便调试，为security设置一个用户名和密码，因为当我们把security的依赖注入时，启动项目会自动跳转到security自己的登录页面，所以必须给定一个用户

```java
spring.thymeleaf.cache=false
spring.security.user.name=user
spring.security.user.password=123456

```

0k,这样环境就搭建好了，可以启动项目看一下

{% img/images/write/security/view.PNG %}

### 认证和授权

+ 权限和认证是在一个类下实现的，刚才也分析了，这个类要继承WebSecurityConfigurerAdapter类，并且重写它的两个方法

```java
package com.gdpi.config;

import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
    //做权限操作
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    //做认证和授权操作
    }

}

```

+ 接下来就是设置权限了,我们可以通过http.authorizeRequests().anMatchers(允许访问的路径).hasRole(允许访问的角色)，如果你要设置多个权限，直接在后面加即可，权限加完后再用分号结束

+ 而http.formLogin()是当我们没有没登录认证时，用户点击模块要让它自动跳到登录页面，不然会报403错误

```java
@Override
protected void configure(HttpSecurity http) throws Exception {

        //权限
        http.authorizeRequests()
                .antMatchers("/").permitAll() //所有用户都可以访问首页
                .antMatchers("/level1/**").hasRole("vip1") //为功能模块设置一个可允许访问的角色
                .antMatchers("/level2/**").hasRole("vip2")
                .antMatchers("/level3/**").hasRole("vip3");

        //自动跳转到登录页面
        http.formLogin()
    }
```

+ 接下来我们要设置用户，因为方便演示，所以没连数据库，这里直接从内存取，正常开发时通过数据库的数据来设置权限的。并且为用户分配相应的权限，通过auth.inMemoryAuthentication().withUser("namunana").password("123456").roles("vip3","vip2"),来设置。顾名思义，withUser用来设置用户名，password用来设置密码，roles为用户分配相应的角色，如果要添加多个用户，通过and()来追加

+ 因为security要求我们要对密码进行硬编码，所以我们要对我们原先的密码进行加密，否则登录不了，进行硬编码是为了防止别人反编译破解我们的密码，这里我们就用BCryptPasswordEncoder的方式进行硬编码

```java
@Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        //认证
        auth.inMemoryAuthentication().passwordEncoder(new BCryptPasswordEncoder())
                .withUser("namunana").password(new BCryptPasswordEncoder().encode("123456")).roles("vip3","vip2")
                .and()
                .withUser("root").password(new BCryptPasswordEncoder().encode("000000")).roles("vip1","vip2","vip3")
                .and()
                .withUser("guest").password(new BCryptPasswordEncoder().encode("111111")).roles("vip1");
    }
```

走到这一步，权限的设置和分配就可以实现了。

### 注销和权限控制

1. 注销

注销功能的实现只需要通过一行代码即可搞定，只需要把一下代码放入configure(HttpSecurity http)方法中即可，logoutSuccessUrl(),是设置注销成功后要跳转的页面，一般是首页或者登录页

```java
http.logout().logoutSuccessUrl("/index");
```

2. 权限控制

_权限是分配了，但是用户体验还没完善，每个用户登录都可以看到所有的功能模块，这不是我们想要的，我们希望用户看到自己有权限访问的模块，对于没有权限访问的模块要隐藏起来，这是security就要整合thymeleaf了。_

+ 首先，我们要导入security整合thymeleaf的命名空间(第二行)

```html
<html lang="en" xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/thymeleaf-extras-springsecurity5">
<head>

```
+ 其次是为模块分配角色(第一行)，这个模块只允许vip1这个角色才能访问，其他模块分配角色亦是如此，不过多介绍，这样就实现了权限的控制了

```html
<div class="column" sec:authorize="hasRole('vip1')">
                <div class="ui raised segment">
                    <div class="ui">
                        <div class="content">
                            <h5 class="content">Level 1</h5>
                            <hr>
                            <div><a th:href="@{/level1/1}"><i class="bullhorn icon"></i> Level-1-1</a></div>
                            <div><a th:href="@{/level1/2}"><i class="bullhorn icon"></i> Level-1-2</a></div>
                            <div><a th:href="@{/level1/3}"><i class="bullhorn icon"></i> Level-1-3</a></div>
                        </div>
                    </div>
                </div>
            </div>
```

+ 权限控制有了，但是还有一个地方没处理，那就是登录和注销。现在的情况是用户没登录时，注销模块依然显示，登录成功时，登录模块依然显示，我们要的效果是用户未登录，显示登录模块，屏蔽注销模块，用户已登录，显示注销模块，屏蔽登录模块。这个功能就要通过isAuthenticated()来判断了

+ 此外，我们还可以在登录成功时做用户名和角色的显示。（第9-10行）

```html
<div sec:authorize="!isAuthenticated()">
    <a class="item" th:href="@{/toLogin}">
         <i class="address card icon"></i> 登录
    </a>
</div>
<!--如果已登录，显示注销和用户名-->
<div sec:authorize="isAuthenticated()">
     <a class="item">
       用户名：<span sec:authentication="name"></span>
       角色：<span sec:authentication="principal.authorities"></span>
     </a>
</div>
<div sec:authorize="isAuthenticated()">
    <a class="item" th:href="@{/toLogin}">
         <i class="sign-out icon"></i> 注销
    </a>
</div>

```

### 记住我和首页定制

1. 记住我

这个功能就是为了下次登录方便而保留用户名和密码，现在大部分应用都有这个功能，勾选了就可以实现，这个功能也可以通过一行代码就可以搞定，由此可晓而知SpringSecurity帮我们整合了多少东西。只需要把一下代码放入configure(HttpSecurity http)方法中即可，rememberMeParameter()方法填写的参数是登录页面记住我所在标签的name属性的值

```java
http.rememberMe().rememberMeParameter("remeber");
```

2. 首页定制

到目前为止，我们用的还是SpringSecurity的登录页面，实际开发中我们要用自己的登录页面，这里也只需要一行代码即可搞定，依然是放入configure(HttpSecurity http)方法中

loginPage(),参数必须和Controller中toLogin方法绑定的url一致

usernameParameter("user") user对应登录页表单用户名绑定的name属性的值

passwordParameter("pwd") pwd对应登录页表单密码绑定的name属性的值

loginProcessingUrl("/login") login对应表单action绑定的url

```java
http.formLogin().loginPage("/toLogin").usernameParameter("user").passwordParameter("pwd").loginProcessingUrl("/login");
```


_到目前为止SpringSecurity的常用操作就介绍完了，相对于Shiro来说，SpringSecurity是比较简单的，大型项目首选SpringSecurity和Shiro,小型项目可以用拦截器。这只是一个入门，想要熟练运用，还需多加练习。下章介绍Shiro。_