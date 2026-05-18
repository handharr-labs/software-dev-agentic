# Android — Network Layer (Retrofit + OkHttp)

## Retrofit Setup <!-- 44 -->

```kotlin
@Module
class NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava3CallAdapterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideOkHttpClient(
        authInterceptor: AuthInterceptor,
        errorInterceptor: ErrorInterceptor,
        loggingInterceptor: HttpLoggingInterceptor
    ): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(errorInterceptor)
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    fun provideLoggingInterceptor(): HttpLoggingInterceptor {
        return HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) HttpLoggingInterceptor.Level.BODY
                    else HttpLoggingInterceptor.Level.NONE
        }
    }
}
```

## Auth Interceptor <!-- 19 -->

```kotlin
class AuthInterceptor @Inject constructor(
    private val tokenManager: TokenManager
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val token = tokenManager.getAccessToken()
        if (token.isNullOrEmpty()) return chain.proceed(chain.request())

        val authenticatedRequest = chain.request().newBuilder()
            .header("Authorization", "Bearer $token")
            .build()
        return chain.proceed(authenticatedRequest)
    }
}
```

## Retrofit API Interface <!-- 31 -->

```kotlin
interface FeatureApi {
    @GET("v1/feature/{id}")
    fun getFeature(@Path("id") id: String): Single<FeatureResponse>

    @GET("v1/features")
    fun getFeatures(
        @Query("page") page: Int,
        @Query("limit") limit: Int
    ): Single<FeatureListResponse>

    @POST("v1/features")
    fun createFeature(@Body request: CreateFeatureRequest): Single<FeatureResponse>

    @PUT("v1/features/{id}")
    fun updateFeature(
        @Path("id") id: String,
        @Body request: UpdateFeatureRequest
    ): Single<FeatureResponse>

    @DELETE("v1/features/{id}")
    fun deleteFeature(@Path("id") id: String): Completable
}
```

Rules:
- `Single<Response>` for endpoints with body; `Completable` for void endpoints
- `@Path` for path segments, `@Query` for query params, `@Body` for request body
- Add `@Provides fun provide[Module]Api(retrofit: Retrofit): [Module]Api` to feature DI module
