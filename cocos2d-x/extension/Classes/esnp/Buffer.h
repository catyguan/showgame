#ifndef  __ESNP_BUFFER_H__
#define  __ESNP_BUFFER_H__

#include <stdint.h>
#include <string>

class ESNPBuffer
{
public:
	static ESNPBuffer* Create(int len, int glen) {
		ESNPBuffer* r = new ESNPBuffer();
		r->Init(len, glen);
		return r;
	}
	void Init(int len, int glen);
	static ESNPBuffer* Create(ESNPBuffer* ptr, int wpos, int rpos) {
		ESNPBuffer* r = new ESNPBuffer();
		r->Init(ptr, wpos, rpos);
		return r;
	}
	void Init(ESNPBuffer* ptr, int wpos, int rpos);	

	int Write(char v);
	int WriteBytes(const char* buf, int c);
	int Read();
	int ReadBytes(char* buf, int c);
	int Remain();
	int Reserve(int sz);
	int Rewrite(int pos, const char* buf, int c);
	int SkipRead(int sz);

	int ReadPos(){return rpos;}
	int WritePos(){return wpos;}
	uint8_t* Buffer(){return buffer;};	
	void Optimize();

	void Reset();
	void ResetRead(){rpos=0;};
	void ResetRead(int p);
	void Clear();
	std::string Dump();

protected:
	bool CheckBuf(int sz);

public:
	ESNPBuffer(void);
	~ESNPBuffer(void);

protected:
	uint8_t* buffer;
	int len, glen;
	int rpos, wpos, dlen;
	int own;
};

#endif