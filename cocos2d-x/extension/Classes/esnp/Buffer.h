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
	static ESNPBuffer* Create(ESNPBuffer* ptr, int pos) {
		ESNPBuffer* r = new ESNPBuffer();
		r->Init(ptr, pos);
		return r;
	}
	void Init(ESNPBuffer* ptr, int pos);	

	int Write(char v);
	int WriteBytes(const char* buf, int c);
	int Read();
	int ReadBytes(char* buf, int c);
	int Remain();

	int Pos(){return pos;}
	uint8_t* Buffer(){return buffer;};
	int Rewrite(int pos, const char* buf, int c);

	void Reset();
	void Clear();
	std::string Dump();

public:
	ESNPBuffer(void);
	~ESNPBuffer(void);

protected:
	uint8_t* buffer;
	int pos, dlen, len, glen;
	int own;
};

#endif