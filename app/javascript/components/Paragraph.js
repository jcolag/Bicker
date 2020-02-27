import React from "react";
import PropTypes from "prop-types";
import PuncButton from "./PuncButton";
import ClauseSpan from "./ClauseSpan";

class Paragraph extends React.Component {
  constructor (props) {
    super(props);
    this.state = {
      avatar: this.props.avatar,
      beenseen: this.props.beenseen,
      callback: this.props.callback,
      children: this.props.children,
      content: this.props.content,
      count: this.props.count,
      indent: this.props.indent,
      pid: this.props.pid,
      pnum: this.props.pnum,
      ts: this.props.ts,
      when: this.props.when,
      who: this.props.who,
    };
  }

  choose (text, idx, pid, pnumber, offset) {
    const punct = [
      '.',
      ',',
      '!',
      '?',
      ';',
      ':',
      '(',
      ')',
      '&',
      '/',
      '&ndash;',
      '&#8212;',
      '&mdash;',
      '&#8211;',
      '&hellip;',
      '&#8230;',
    ];

    if (punct.indexOf(text) >= 0) {
      return([
        <PuncButton
          callback={this.state.callback}
          count={idx}
          key={idx}
          offset={offset}
          pid={pid}
          pnumber={pnumber}
          punc={text}
        />,
        1,
      ]);
    } else {
      return([
        <ClauseSpan
          clause={text}
          count={idx}
          key={idx}
          offset={offset}
          pid={pid}
        />,
        0,
      ]);
    }
  }

  paragraphParts (self, contentArray, pid, pnumber) {
    const components = [];
    const lengths = {
      '.': 1,
      ',': 1,
      '!': 1,
      '?': 1,
      ';': 1,
      ':': 1,
      '(': 1,
      ')': 1,
      '&': 1,
      '/': 1,
      '&ndash;': 2,
      '&#8212;': 2,
      '&mdash;': 3,
      '&#8211;': 3,
      '&hellip;': 3,
      '&#8230;': 3,
    };
    let length = 0;
    let marks = 0;

    contentArray.map(function (c, idx) {
      const corrlen = Object.prototype.hasOwnProperty.call(lengths, c) ?
        lengths[c] : c.length;
      const component = self.choose(c, idx, pid, pnumber, length);
      marks += component[1];
      components.push(component[0]);
      length += corrlen;
    });
    if (marks === 0 && this.state.children.length === 0) {
      const count = contentArray.length;
      components.push(<PuncButton
          callback={this.state.callback}
          count={count}
          key={count}
          offset={length}
          pid={pid}
          pnumber={pnumber}
          punc='&para'
        />);
    }
    return components;
  }

  paragraphChildren(self, children, indent) {
    const result = [];

    if (
      children === null ||
      typeof children === 'undefined' ||
      children.length === 0
    ) {
      return;
    }

    children.forEach(c => result.push(<Paragraph
      avatar={c.avatar}
      beenseen={c.beenseen}
      callback={this.state.callback}
      children={c.children}
      content={c.content}
      indent={indent + 1}
      key={`child-${c.id}`}
      pid={c.id}
      pnum={c.id}
      ts={c.created_at.toString()}
      when={c.when}
      who={c.who}
    />));
    return result;
  }

  render () {
    const array = JSON.parse(this.state.content);
    const para = this.paragraphParts(
      this,
      array,
      this.state.pid,
      this.state.pnum
    );
    const indent = this.state.indent === null
      || typeof this.state.indent === 'undefined'
      ? 0
      : this.state.indent;
    const children = this.paragraphChildren(
      this,
      this.state.children,
      indent
    );
    const pad = `${indent}em`;
    const pclass = this.state.beenseen ? "msg-paragraph" : "msg-new-paragraph"
    return (
      <React.Fragment>
        <div
          style={{
            marginLeft: pad
          }}
        >
          <div className={ pclass }>
            <span
              className="msg-par-text"
            >
              { para }
            </span>
            <p className="msg-par-avatar">
              <a href='/'>
                <img draggable="false" src={ this.state.avatar } />
              </a>
              <br />
              <span className="id-time">{ this.state.who.login }</span>
              <br />
              <span
                className="id-time"
                title={ this.state.ts }
              >
                { this.state.when } ago
              </span>
            </p>
          </div>
          <div>
            { children }
          </div>
        </div>
      </React.Fragment>
    );
  }
}

Paragraph.propTypes = {
  avatar: PropTypes.string,
  beenseen: PropTypes.bool,
  callback: PropTypes.func,
  count: PropTypes.number,
  indent: PropTypes.number,
  pid: PropTypes.number,
  pnum: PropTypes.number,
  ts: PropTypes.string,
  when: PropTypes.string,
  who: PropTypes.object,
};
export default Paragraph
